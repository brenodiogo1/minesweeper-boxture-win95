Rails.application.routes.draw do
  root "games#index"
  
  resources :games, only: [:index, :show, :create] do
    member do
      post :reveal_cell
      post :toggle_flag
      post :reset
    end
  end
  
  resources :scores, only: [:index, :new, :create]
end