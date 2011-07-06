Rails.application.routes.draw do

  namespace :admin do

    namespace :fulfillment do
      match 'dashboard' => 'dashboard#index'

      resources :po_files do
        collection do
          delete :purge
        end
      end

      resources :poa_files do
        collection do
          delete :purge
        end

        member do
          post :import
        end
      end

      resource :settings

    end

    resources :orders do
      member do
        get :fulfillment
      end
    end


  end


end
