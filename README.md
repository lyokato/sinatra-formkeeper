# Sinatra::FormKeeper

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'sinatra-formkeeper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinatra-formkeeper

## Usage

### Synopsis

    require 'sinatra/formkeeper'

    get '/login' do
      form do
        filters :strip, :my_filter
        field :username, :present => true, :length => 4..8
        field :password, :present => true, :length => 4..8
      end
      if form.failed?
        "login failed"
      else
        "login success " + form[:username] + ":" + form[:password]
      end
    end

### 0: Preparation

At your application file's header, add 'require' line for this library.

    require 'sinatra/formkeeper'

And if your application is Sinatra::Base inheritance type, register Sinatra::FormKeeper

    class MyApp < Sinatra::Base
      register Sinatra::FormKeeper
      ...
    end

### 1: Building rules

In your routing block, you should build a form-rule at first, 
like following

    post '/entry' do 
      form do
        filters :strip
        field :title,   :present => true, :length => 4..20
        field :message, :present => true, :length => 0..200
      end
      ...
    end

Calling 'form' with block which includes rule-setting,
you can build a form-rule.
There are some DSL-method to build rules. In this example, 'filters' and 'field' are written.

### 2: Check if user's input is valid or not

'form.failed?' can be used to judge if user's input is valid for the rule you build.

    post '/entry' do 
      form do
        ...
      end
      if form.failed?
        # user's input is invalid
      else
        # user's input is valid!
      end
    end

### 3: Pick up valid data

After validation is proccessed without any failure,
you can implement your domain logic with valid parameters.

'form[:field_name]' can be used to pick up a valid data.
This data you can obtain through this method is a filtered data
according to the rule you build (if you set a 'filters' rule).

    post '/entry' do 
      form do
        ...
      end
      if form.failed?
        ...
      else
        # do something with valid data
        Database.insert( :title => form[:field], :message => form[:message] )
      end
    end

### 4: Check if what field has failed?

When validation is failed, you might want to provide user
same form again, with error message that describes what fields was invalid.
For this purpose, use 'failed_on?' method.

    post '/entry' do 
      form do
        ...
      end
      if form.failed?
        erb :entry
      else
        ...
      end
    end
    __END__
    @@ entry
    <html>
    <head><title>Entry</title></head>
    <body>
    <% if form.failed? %>
      <% if form.failed_on?(:title) %>
      <p>Title is invalid</p>
      <% end %>
      <% if form.failed_on?(:message) %>
      <p>Message is invalid</p>
      <% end %>
    <% end %>
      <form action="/entry" method="post">
      <label>Title</label><input type="text" name="title"><br />
      <label>Message</label><textarea name="message"></textarea>
      <input type="submit" value="Post this entry"> 
      </form> 
    </body>
    </html>

### 5: Check if what field and constraint has failed?

You can pass constraint-type to 'failed_on?' as a second argument.
This provides you a way to show detailed error-messages.

    post '/entry' do 
      form do
        ...
      end
      if form.failed?
        erb :entry
      else
        ...
      end
    end
    __END__
    @@ entry
    <html>
    <head><title>Entry</title></head>
    <body>
    <% if form.failed? %>
      <% if form.failed_on?(:title, :present) %>
        <p>Title not found</p>
      <% end %>
      <% if form.failed_on?(:title, :length) %>
        <p>Title's length is invalid </p>
      <% end %>
      <% if form.failed_on?(:message, :present) %>
        <p>Message not found</p>
      <% end %>
    <% end %>
      <form action="/entry" method="post">
      <label>Title</label><input type="text" name="title"><br />
      <label>Message</label><textarea name="message"></textarea>
      <input type="submit" value="Post this entry"> 
      </form> 
    </body>
    </html>

### 6: Fill in form

In many case you might want to fill in form with user's last input.
Do like following. 'fill_in_form' automatically fill the fields with 'params'

    post '/entry' do 
      form do
        ...
      end
      if form.failed?
        output = erb :entry
        fill_in_form(output)
      else
        ...
      end
    end

### 7: Message Handling

You can aggregate a error messages into external yaml file.

    --- messages.yaml
    login:
      username:
        present: input name!
        length: intput name (length should be between 0 and 10)
      email:
        DEFAULT: input correct email address
    post_entry:
      title:
        present: Title not found
    DEFAULT:
      username:
        present: username not found
    ... 

DEFAULT is a special type. If it can't find setting for indicated validation-type, it uses message set for DEFAULT.
After you prepare a yaml file, load it.

    form_messages File.expand_path(File.join(File.dirname(__FILE__), 'config', 'form_messages.yaml'))
    post '/entry' do 
      ...
    end

You can show messages bound to indicated action-name you set in yaml.

    <html>
      <head><title>Entry</title></head>
      <body>
      <% if form.failed? %> 
        <ul>
        <% form.messages(:post_entry).each do |message|  %>
          <li><%= message %></li>
        <% end %>
        </ul>
      <% end %>
      </body>
    </html>

If you want to show messages for each field, separately, of course you can.

    <html>
      <head><title>Entry</title></head>
      <body>
      <form>
      <% if form.failed? %> 
        <ul>
        <% form.messages(:login, :username).each do |message|  %>
          <li><%= message %></li>
        <% end %>
        </ul>
      <% end %>
      <label>username</label><input type="text" name="username">
      <% if form.failed? %> 
        <ul>
        <% form.messages(:login, :password).each do |message|  %>
          <li><%= message %></li>
        <% end %>
        </ul>
      <% end %>
      <label>password</label><input type="text" name="password">
      </body>
    </html>

### 8: Custom Filter

### 9: Custom Validator

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
