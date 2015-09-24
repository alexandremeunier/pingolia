Rails.application.routes.draw do
  scope module: 'api/v1', path: 'api/1' do 
    resources :pings, only: :create do 
      get ':origin/hours', action: :hours, as: :hours, on: :collection
    end
  end

  root 'home#index'
end
