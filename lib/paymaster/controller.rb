class Paymaster::Controller < ActionController::Base

  protect_from_forgery only: []

  def success
    retval = Paymaster.interface_class.success(params)
    redirect_to retval if retval.is_a? String
  end

  def fail
    retval = Paymaster.interface_class.fail(params)
    redirect_to retval if retval.is_a? String
  end

  def callback
    Paymaster.interface_class.callback(params)
    render nothing: true
  end

end