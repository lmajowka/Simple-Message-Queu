Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  match '/SendMessage', to: 'messages#send_message', via: :post
  match '/ReceiveMessage', to: 'messages#receive_message', via: :get

end
