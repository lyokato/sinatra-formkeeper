require 'sinatra'
require 'sinatra/formkeeper'

form_messages File.expand_path(File.join(File.dirname(__FILE__), 'messages.yaml'))

form_filter :my_filter do |value|
  value.capitalize
end

get '/login' do
  erb :login
end

post '/login' do
  form do
    filters :strip, :my_filter
    field :username, :present => true, :length => 4..8
    field :password, :present => true, :length => 4..8
  end
  if form.failed?
    output = erb :login
    fill_in_form(output)
  else
    "login success " + form[:username] + ":" + form[:password]
  end
end

__END__

@@ login
<html>
<head>Login</head>
<body>
<% if form.failed? %>
<p>found invalid params</p>
  <ul>
<% form.messages(:login).each do |message| %>    <li><%= message %></li> 
<% end %>  </ul>
<% end %>
<form action="/login" method="post">
<input type="text" name="username" />
<input type="text" name="password" />
<input type="submit" value="login" />
</form>
</body>
</html>

