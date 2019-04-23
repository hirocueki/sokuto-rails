Rails.application.routes.draw do
  root to: "questions#index"
  devise_for :users, controllers: {
      registrations: 'users/registrations'
  }

  resources :questions, only: %i(index show) do
    collection do
      get 'tagged/:tag_name', to: 'questions#tagged'
    end
    resources :answers, only: %i(new create)
  end

  resources :tags, only: %i(index)

  resources :users, only: %i(index show)

  namespace :loggedin do
    resources :questions, only: %i(new create edit update destroy) do
      member do
        put "up_vote", to: "questions#up_vote"
        put "down_vote", to: "questions#down_vote"
      end
    end
    # 自分のプロフィールデータを更新するのであれば単数形でもよいのでは？
    # モデル名と異なるが profile や mypage もわかりやすくてよいのでは？
    resource :users, only: %i(edit update)
  end
end
