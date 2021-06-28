Rails.application.routes.draw do
  
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", passwords: "users/passwords" }

  post 'following/follow'
  post 'following/unfollow'
  post 'following/search'
  post 'following/hide'
  post 'following/unhide'
  get 'following/hidden'

  get 'tags/interests'
  get 'tags/talents'

  resources :users, only: %i[show] do
    get :avatar, on: :member
    get :profile, on: :member
  end

  post 'rails/active_storage/direct_uploads', to: 'direct_uploads#create'
  get '/resource/password', to: 'devise/password#create'

  resource :user, only: [:show, :update]

  
end
