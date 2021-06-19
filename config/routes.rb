Rails.application.routes.draw do
  
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", passwords: "users/passwords" }

  get 'friendship/create'
  post 'friendship/search'

  resources :users, only: %i[show] do
    get :avatar, on: :member
    get :profile, on: :member
  end

  post 'rails/active_storage/direct_uploads', to: 'direct_uploads#create'
  get '/resource/password', to: 'devise/password#create'

  resource :user, only: [:show, :update]

  
end
