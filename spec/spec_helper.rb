require 'rubygems'
require 'bundler/setup'
require 'rack/test'
require 'rspec'

require File.expand_path(File.join(File.dirname(__FILE__), 'app.rb'))

set :environment, :test
set :run, false
set :raise_error, true
set :logging, false

