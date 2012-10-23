#--
# Copyright (C) 2012 Lyo Kato, <lyo.kato _at_ gmail.com>.
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions: 
#
# The above copyright notice and this permission notice shall be 
# included in all copies or substantial portions of the Software. 
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

require "sinatra/formkeeper/version"
require 'formkeeper'

module Sinatra
  # = Sinatra::FormKeeper
  #
  # Example:
  #
  #   require 'sinatra/base'
  #   require 'sinatra/formkeeper'
  #
  #   module MyApp < Sinatra::Base
  #
  #     register Sinatra::FormKeeper
  #
  #     def post '/login' do
  #
  #       form do 
  #         filters :strip
  #         field :username, :present => true, :length => 4..8, :ascii => true
  #         field :password, :present => true, :length => 4..8, :ascii => true
  #       end
  #
  #       # check if validation has failed or not
  #       if form.failed?
  #         output = erb :login
  #         fill_in_form(output)
  #       else
  #         # you can use filtered, valid parameters through form[key]
  #         authenticate(form[:username], form[:password])
  #         ...
  #         redirect '/mypage'
  #       end
  #     end
  #   end
  #
  #   @@ login
  #   <html>
  #   <head><title>Login</title></head>
  #   <body>
  #   <% if form.failed? %>
  #     <p>Found invalid input, check it and try again.</p>
  #   <% end %>
  #   <form action="/login" method="post">
  #     <label>name</label><input type="text" name="username" /><br />
  #     <label>password</label><input type="password" name="password" /><br />
  #     <input type="submit" value="login">
  #   </form>
  #   </body>
  #   </html>
  #
  module FormKeeper

    def form_filter(name, &block)
      ::FormKeeper::Validator.register_filter name, 
        ::FormKeeper::Filter::Custom.new(block)
    end

    def form_constraint(name, &block)
      ::FormKeeper::Validator.register_constraint name, 
        ::FormKeeper::Constraint::Custom.new(block)
    end

    def form_messages(arg)
      case arg
      when String
        messages = ::FormKeeper::Messages.from_file(arg)
      when Hash
        messages = ::FormKeeper::Messages.new(arg)
      else
        raise ArgumentError.new
      end
      set :form_failure_messages, messages
    end
    module Helpers
      def reset_form
        @form_report = ::FormKeeper::Report.new
      end
      def form(&block)
        if block
          rule = ::FormKeeper::Rule.new
          rule.instance_eval(&block)
          messages = settings.form_failure_messages
          @form_report = 
            settings.form_validator.validate(params, rule, messages)
        end
        @form_report
      end
      def fill_in_form(output, others={})
        filled = settings.form_respondent.fill_up(output, params.merge(others))
        output.replace(filled)
        output
      end
    end
    def self.registered(app)
      app.helpers Helpers
      app.set :form_validator, ::FormKeeper::Validator.new
      app.set :form_respondent, ::FormKeeper::Respondent.new
      app.set :form_failure_messages, nil
      app.before do
        reset_form
      end
    end
  end
  register FormKeeper
end
