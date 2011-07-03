Rails.application.routes.draw do

  namespace :admin do
    match '/fulfillment' => 'fulfillment#index'

    resources :po_files do
      collection do
        delete :purge
      end
    end

    resources :orders do
      member do
        get :fulfillment
      end
    end

  end


end
