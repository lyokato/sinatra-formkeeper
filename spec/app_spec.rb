require 'spec_helper'

describe Sinatra::FormKeeper do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end

  describe "form validation" do
    before  { get '/login' }
    subject { last_response }
    it "responds" do
      should be_ok
    end
    it "returns repsonse body" do
      subject.body.should == <<-HTML
<html>
<head>Login</head>
<body>
<form action="/login" method="post">
<input type="text" name="username" />
<input type="text" name="password" />
<input type="submit" value="login" />
</form>
</body>
</html>

      HTML
    end
  end

  describe "form validation with valid params" do
    before  { post '/login', :username => ' john', :password => 'foobar'  }
    subject { last_response }
    it "responds" do
      should be_ok
    end
    it "returns repsonse body" do
      subject.body.should == "login success John:Foobar"
    end
  end

  describe "form validation with invalid params" do
    before  { post '/login', :username => 'John', :password => 'Foo'  }
    subject { last_response }
    it "responds" do
      should be_ok
    end
    it "returns repsonse body" do
      subject.body.should == <<-HTML
<html>
<head>Login</head>
<body>
<p>found invalid params</p>
  <ul>
    <li>Password's length should be between 4 and 8</li> 
  </ul>
<form action="/login" method="post">
<input type="text" name="username" value="John" />
<input type="text" name="password" value="Foo" />
<input type="submit" value="login" />
</form>
</body>
</html>

      HTML
    end

  end

  describe "form validation with multiple invalid params" do
    before  { post '/login', :username => 'Bar', :password => 'Foo'  }
    subject { last_response }
    it "responds" do
      should be_ok
    end
    it "returns repsonse body" do
      subject.body.should == <<-HTML
<html>
<head>Login</head>
<body>
<p>found invalid params</p>
  <ul>
    <li>Name's length should be between 4 and 8</li> 
    <li>Password's length should be between 4 and 8</li> 
  </ul>
<form action="/login" method="post">
<input type="text" name="username" value="Bar" />
<input type="text" name="password" value="Foo" />
<input type="submit" value="login" />
</form>
</body>
</html>

      HTML
    end

  end
end
