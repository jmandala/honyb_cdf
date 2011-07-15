Rails.application.routes.draw do

  namespace :admin do

    namespace :fulfillment do
      match 'dashboard' => 'dashboard#index'
      resource :settings

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

      resources :asn_files do
        collection do
          delete :purge
        end

        member do
          post :import
        end
      end

      resources :cdf_invoice_files do
        collection do
          delete :purge
          post :load
        end

        member do
          post :import
        end
      end


    end

    resources :orders do
      member do
        get :fulfillment
      end
    end


  end


end
