Rails.application.routes.draw do
  use_doorkeeper
  post '/info', to: 'application#info'

  resources :users do
    collection do
      get 'unlock_access/:uuid(/:reset)', to: 'users#check_uuid'
      post 'password-forgotten', to: 'users#password_forgotten'
      put 'change-password', to: 'users#change_password'
    end
  end

  resources :pias do
    collection do
      get 'example'
    end
    member do
      post 'duplicate'
    end
    resources :answers
    resources :comments
    resources :evaluations
    resources :measures
    resources :revisions, except: :update
    resources :attachments do
      collection do
        get '/signed', to: 'attachments#signed'
      end
    end
    collection do
      post '/import', to: 'pias#import'
    end
  end
  resources :structures
  resources :knowledge_bases do
    resources :knowledges
  end

  get '/saml/metadata', to: 'saml#metadata'
  get '/saml/sso', to: 'saml#sso'
  get '/saml/logout', to: 'saml#logout'
  post '/saml/acs', to: 'saml#consume'
  get '/saml/slo', to: 'saml#slo'
end
