require 'spec_helper'

describe Sinatra::FormKeeper do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end

  describe "form validation" do
    before  { get '/' }
    subject { last_response }
    it "responds" do
      should be_ok
    end
    it "returns repsonse body" do
      subject.body.should == "hello" 
    end
  end

  describe "form validation with valid params" do
    before  { post '/login', :username => ' John', :password => 'Foobar'  }
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
      subject.body.should == "login failed" 
    end
  end
end
