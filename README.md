# Sinatra::FormKeeper

This module provides you a easy way for form-validation and fill-in-form on your sinatra application

## Installation

Add this line to your application's Gemfile:

    gem 'sinatra-formkeeper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinatra-formkeeper

## Usage

### Synopsis

```ruby
require 'sinatra/formkeeper'

get '/sign_up' do
  form do
    filters :strip, :my_filter
    field :username, :present => true, :length => 4..8
    field :age, :present => true, :int => { :gte => 18 }
    field :password01, :present => true, :length => 4..8
    field :password02, :present => true, :length => 4..8
    same :same_password, [:password01, :password02]
  end
  if form.failed?
    "signup failed"
  else
    "singup success " + form[:username]
  end
end
```

### 0: Preparation

At your application file's header, add `require` line for this library.

```ruby
require 'sinatra/formkeeper'
```

And if your application is `Sinatra::Base` inheritance type, register `Sinatra::FormKeeper`

```ruby
class MyApp < Sinatra::Base
  register Sinatra::FormKeeper
  #...
end
```

### 1: Building rules

In your routing block, you should build a form-rule at first, 
like following

```ruby
post '/entry' do 
  form do
    filters :strip
    field :title,   :present => true, :length => 4..20
    field :message, :present => true, :length => 0..200
  end
  #...
end
```

Calling `form` with block which includes rule-setting,
you can build a form-rule.
There are some DSL-method to build rules. In this example, `filters` and `field` are written.

#### filters

You can set `filters`. All input parameters are filtered by indicated filtering feature
The filtering process is executed before validation.

```ruby
form do
  filters :strip
  #...
end
```

You can set multiple filters at once

```ruby
form do
  filters :strip, :downcase
  #...
end
```

All preset filters are described at [8: Preset Filters](#8-preset-filters)

#### field

You can add a setting for each field

```ruby
form do
  field :field_name, :present => true, length => 0..10
  #...
end
```

This constraint works for an input form named as `field_name`, for instance

```html
<input type="text" name="field_name" />
```

And key-value pares are following the field name.
They are constraints set for the field.
You can add your favorite constraints here.

All preset constraints are described at [9: Preset Constraints](#9-preset-constraints)
Read the chapter for more detail.

`:present` is a special constraint. if parameter not found for the field which
set `:present` constraint, the field will be marked as *not present*,
and other validation for rest constraints won't be executed.

You also can set :default

```ruby
form do
  field :field_name, :default => 'Default Value', :length => 0..10
  #...
end
```

When it's set, if parameter not found, the indicated value will be set
and other validation for rest constraints won't be executed.

You aren't allowed to set both *:present* and *:default* at same time.

And you can set filters here,
if you don't want to filter all the parameters included in the request.
This filtering setting only affets on `:field_name`.

```ruby
form do
  field :field_name, :present => true, filters => [:strip, :downcase]
  #...
end
```

You can set as just one single symbol, if you don't need multiple filters.

```ruby
form do
  field :field_name, :present => true, filters => :strip
  #...
end
```

#### selection

You also can set the rule like this.

```ruby
form do
  selection :field_name, :count => 1..3, int => true
  #...
end
```

This is just for field which has multiple values.
For instance,

```html
<input type="checkbox" name="field_name[]" value="1" checked>
<label>check1</label>
<input type="checkbox" name="field_name[]" value="2" checked>
<label>check2</label>
<input type="checkbox" name="field_name[]" value="3" checked>
<label>check3</label>
```

Or

```html
<select name="favorite[]" multiple>
  <option value="1" selected="selected">white</option>
  <option value="2">black</option>
  <option value="3">blue</option>
</select>
```

Rack request handle such type of name (exp: field_name[]) as Array.
For this type of input, use `selection` method.
In this case, you must use `:count` constraints instead of `:present`.

#### combination

There is another special rule, *Combination*

```ruby
form do
  combination :same_address, :fields => ["email01", "email02"], :same => true
  combination :favorite_color, :fields => ["white", "black", "blue"], :any => true
end
```

Set rule-name as a first argument.
And you should set multiple target fields.
And one constraint like (:same => true), or (:any => true).

`:same` and `:any` are called as *Combination Constraint*
For this purpose, formkeeper provides you a simple way to do same things.

```ruby
form do
  same :same_address, ["email01", "email02"]
  any :favorite_color, ["white", "black", "blue"]
end
```

You can call a name of *Combination Constraints* as a method.
Followed by rule-name and target-fields.

All preset constraints are described at [10: Preset Combination Constraints](#10-preset-combination-constraints)

### 2: Check if user's input is valid or not

`form.failed?` can be used to judge if user's input is valid for the rule you build.

```ruby
post '/entry' do 
  form do
    #...
  end
  if form.failed?
    # user's input is invalid
  else
    # user's input is valid!
  end
end
```

### 3: Pick up valid data

After validation is proccessed without any failure,
you can implement your domain logic with valid parameters.

`form[:field_name]` can be used to pick up a valid data.
This data you can obtain through this method is a filtered data
according to the rule you build (if you set a `filters` rule).

```ruby
post '/entry' do 
  form do
    #...
  end
  if form.failed?
    #...
  else
    # do something with valid data
    Database.insert( :title => form[:field], :message => form[:message] )
  end
end
```

### 4: Check if what field has failed?

When validation is failed, you might want to provide user
same form again, with error message that describes what fields was invalid.
For this purpose, use `failed_on?` method.

```ruby
post '/entry' do 
  form do
    #...
  end
  if form.failed?
    erb :entry
  else
    #...
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
```

### 5: Check if what field and constraint has failed?

You can pass constraint-type to `failed_on?` as a second argument.
This provides you a way to show detailed error-messages.

```ruby
post '/entry' do 
  form do
    #...
  end
  if form.failed?
    erb :entry
  else
    #...
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
```

### 6: Fill in form

In many case you might want to fill in form with user's last input.
Do like following. `fill_in_form` automatically fill the fields with `params`

```ruby
post '/entry' do 
  form do
    #...
  end
  if form.failed?
    output = erb :entry
    fill_in_form(output)
  else
    #...
  end
end
```

### 7: Message Handling

You can aggregate a error messages into external yaml file.

```yaml
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
-- ... 
```

`DEFAULT` is a special type. If it can't find setting for indicated validation-type, it uses message set for `DEFAULT`.
After you prepare a yaml file, load it.

```ruby
form_messages File.expand_path(File.join(File.dirname(__FILE__), 'config', 'form_messages.yaml'))
post '/entry' do 
  #...
end
```

You can show messages bound to indicated action-name you set in yaml.

```html
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
```

If you want to show messages for each field, separately, of course you can.

```html
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
```

### 8: Preset Filters

#### strip
#### downcase
#### upcase

### 9: Preset Constraints

#### length

calculate length. this constraint use String#length internally
You can set integer.

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :length => 10
  end
  #...
end
```

Or as range

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :length => 4..10
  end
  #...
end
```

#### bytesize

Calculate byte size. this constraint use String#bytesize internally
You can set integer.

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :bytesize => 10
  end
  #...
end
```

Or as range

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :bytesize => 4..10
  end
  #...
end
```

#### ascii

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :ascii => true
  end
  #...
end
```

#### regexp

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :regexp => %r{regexp}
  end
  #...
end
```

#### int

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :int => true
  end
  #...
end
```

Fore more detailed constraint,
You can use following options as a hash.

* gt: This means >
* gte: This means >=
* lt: This means <
* lte: This means <=
* between: Or you can set Range object

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :int => { :gt => 5, :lt => 10 }
  end
  #...
end
```

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :int => { :gte => 5, :lte => 10 }
  end
  #...
end
```

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :int => { :between => 5..10 }
  end
  #...
end
```

#### uint

Unsined integer. This doesn't allow lass than zero.
Except for that, it behaves same as integer

```ruby
post '/entry' do 
  form do
    field :field01, :present => true, :uint => { :between => 5..10 }
  end
  #...
end
```

#### alpha

Alphabet

#### alpha_space

Alphabet and Space

#### alnum

Alphabet and Number

#### alnum_space

Alphabet, Number and Space

#### email

Email-Address

```ruby
post '/entry' do 
  form do
    field :your_address, :present => true, :email => true, :bytesize => 10..255
  end
  #...
end
```

#### uri

Limit a scheme as Array

```ruby
post '/entry' do 
  form do
    field :your_address, :present => true, :uri => [:http, :https], :bytesize => 10..255
  end
  #...
end
```

```ruby
post '/entry' do 
  form do
    field :your_address, :present => true, :uri => [:http], :bytesize => 10..255
  end
  #...
end
```

If your scheme option is only one.
You can set as a String.

```ruby
post '/entry' do 
  form do
    field :your_address, :present => true, :uri => :http, :bytesize => 10..255
  end
  #...
end
```

### 10: Preset Combination Constraints

#### same
#### any
#### date
#### time
#### datetime

### 11: Utilize Plugins

```ruby
require 'formkeeper/japanese' 

post '/entry' do
  form do
    filters :zenkaku2hankaku
  end
end
```

### 12: Custom Filter

```ruby
form_filter :my_capitalize_filter do |value|
  value.capitalize
end

post '/entry' do
  form do
    filters :my_capitalize_filter
  end
end
```

### 13: Custom Constraint

## See Also

* https://github.com/lyokato/formkeeper/
* https://github.com/lyokato/formkeeper-japanese/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
