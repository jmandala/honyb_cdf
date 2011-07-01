Rails.application.routes.draw do

  namespace :admin do
    match '/fulfillment' => 'fulfillment#index'
    match '/fulfillment/create_po' => 'fulfillment#create_po'
    # Not sure why, but the following do not work!
    # get :fulfillment
    # resources :fulfillment
  end

end
