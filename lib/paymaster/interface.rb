#require 'cgi'
#require 'net/http'
#require 'net/https'
#require 'open-uri'
#require 'rexml/document'
#require 'digest/hmac'
#require 'base64'

class Paymaster::Interface

  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  @@signature_keys = [:LMI_MERCHANT_ID,
                      :LMI_PAYMENT_NO,
                      :LMI_SYS_PAYMENT_ID,
                      :LMI_SYS_PAYMENT_DATE,
                      :LMI_PAYMENT_AMOUNT,
                      :LMI_CURRENCY,
                      :LMI_PAID_AMOUNT,
                      :LMI_PAID_CURRENCY,
                      :LMI_PAYMENT_SYSTEM,
                      :LMI_SIM_MODE]

  @@default_options = {
      language: 'ru',
  }

  def initialize(options)
    @options = @@default_options.merge(options.symbolize_keys)
  end

  def base_url
    'https://paymaster.ru/Payment/Init'
  end

  def self.success(params, controller)
    success_implementation(params[:order_id], controller)
  end

  def self.fail(params, controller)
    fail_implementation(params[:order_id] , controller)
  end

  def self.callback(params, controller)
    if check_response_signature(params)
      success_callback_implementation(params)
    else
      fail_callback_implementation(params)
    end
  end

  def self.check_response_signature(params)
    params['LMI_HASH'] == generate_signature(params)
  end

  def self.generate_signature(params)
    signature_array = []
    @@signature_keys.each do |key|
      signature_array << params[key.to_s] || ''
    end
    signature_array << get_options()[:key]
    signature_string = signature_array.join(';')
    Base64.encode64(Digest::MD5.digest(signature_string)).gsub("\n", '')
  end

  class << self
    %w{success fail success_callback fail_callback}.map{|m| m + '_implementation'} + ['get_options_by_notification_key'].each do |m|
      define_method m.to_sym do |*args|
        raise NoMethodError, "Paymaster::Interface.#{m} should be defined by application"
      end
    end
  end

  # создание урла для оплаты
  def init_payment_url(order_id, amount)
    url_options = init_payment_options(order_id, amount)
    "#{base_url}?" + url_options
  end

  def init_payment_options(order_id, amount)
    options = {

        LMI_MERCHANT_ID:          @options[:merchant_id],
        LMI_PAYMENT_AMOUNT:       amount.to_s,
        LMI_PAYMENT_NO:           order_id,
        LMI_CURRENCY:             'RUB',
        LMI_PAYMENT_DESC:         @options[:LMI_PAYMENT_DESC] || "Inner order N#{order_id}",
    }

    # if test mode On
    if @options[:LMI_SIM_MODE]
      options[:LMI_SIM_MODE] = @options[:LMI_SIM_MODE]
    end

    query_string(options)
  end

  def query_string(params) #:nodoc:
    params.map do |name, value|
      "#{CGI::escape(name.to_s)}=#{CGI::escape(value.to_s)}"
    end.join('&')
  end

end
