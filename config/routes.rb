Rails.application.routes.draw do
  devise_for :users
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
end
