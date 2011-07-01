Rails.application.routes.draw do

  namespace :admin do
    match '/fulfillment' => 'fulfillment#index'

#    scope 'fulfillment' do
    resources :po_files
#    end

  end


end
