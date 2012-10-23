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

### Getting Started

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
