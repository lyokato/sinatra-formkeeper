require 'sinatra'
require 'sinatra/formkeeper'

get '/' do
  "hello"
end

post '/login' do
  form do
    filters :strip
    field :username, :present => true, :length => 4..8
    field :password, :present => true, :length => 4..8
  end
  if form.failed?
    "login failed"
  else
    "login success " + form[:username] + ":" + form[:password]
  end
end

__END__

