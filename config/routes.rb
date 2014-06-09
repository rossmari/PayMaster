Paymaster::Engine.routes.draw do

  controller :paymaster do
    get '/success'  => :success,  :as => :on_success
    get '/fail'     => :fail,     :as => :on_fail
    post '/callback' => :callback, :as => :on_callback
  end

end