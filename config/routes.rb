ShpostPackage::Application.routes.draw do
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  root 'welcome#index'

  devise_for :users, controllers: { sessions: "users/sessions" }

  resources :user_logs, only: [:index, :show, :destroy]

  resources :units do
    resources :users, :controller => 'unit_users'
  end

  resources :users do
     resources :roles, :controller => 'user_roles'
  end

  
  resources :businesses

  resources :query_results do
    collection do 
      get 'import'
      post 'import' => 'query_results#import'
      get 'query_result_index'
      post 'query_result_index'
      post 'export'
      get 'ywtb_query_result_index'
      get 'pkp_result_index'
      post 'pkp_result_index'
      post 'pkp_export'
    end
  end

  resources :import_files do
    member do 
      get 'download'
      post 'download' => 'import_files#download'
      get 'insert_data'
      get 'err_download'
      post 'err_download' => 'import_files#err_download'
    end
  end

  resources :up_downloads do
    collection do 
      get 'up_download_import'
      post 'up_download_import' => 'up_downloads#up_download_import'
      
      get 'to_import'
      
      
    end
    member do
      get 'up_download_export'
      post 'up_download_export' => 'up_downloads#up_download_export'
    end
  end

  resources :return_results do
    collection do 
      get 'import'
      post 'import' => 'return_results#import'
      get 'return_result_index'
      post 'return_result_index'
      post 'export'
      get 'return_scan'
      get 'find_query_result'
      get 'do_return'
    end
  end

  resources :qr_attrs

  resources :return_reasons


  match "/shpost_package/standard_interface/mail_push" => "standard_interface#mail_push", via: [:get, :post]

  match "/shpost_package/standard_interface/mail_query" => "standard_interface#mail_query", via: [:get, :post]

  match "/shpost_package/standard_interface/mail_query_in_time" => "standard_interface#mail_query_in_time", via: [:get, :post]

  match "/shpost_package/standard_interface/mail_query_in_local" => "standard_interface#mail_query_in_local", via: [:get, :post]
  
end
