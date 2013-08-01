# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

require 'rack/lint'
require 'rack/mock'
require 'cepa-health'

describe CepaHealth::Middleware do

  before(:each) do 
    CepaHealth.clear_probes!
    CepaHealth.key = nil
  end

  let(:rackapp) do
    app = ->(e) { [200, { 'Content-Type' => 'text/plain' }, ["Boom"]] }
    Rack::Lint.new CepaHealth::Middleware.new(app)
  end

  it "should not match other URLs" do
    code, headers, body = get("/someotherpage.html")
    body.should == "Boom"
  end

  it "should match the healthy URL" do
    code, headers, body = get("/healthy.html")
    code.should == 200
    body.should_not == "Boom"
  end

  it "should return a 200 OK for passing probes" do
    CepaHealth.register("VeryUniqueTestIFear") { true }
    code, headers, body = get("/healthy.html")
    code.should == 200
    body.should =~ /VeryUniqueTestIFear/
  end

  it "should return a 500 Error for failing probes" do
    CepaHealth.register("VeryUniqueTestIFear") { true }
    CepaHealth.register("TotallyUniqueFailure") { false }
    code, headers, body = get("/healthy.html")
    code.should == 500
    body.should =~ /TotallyUniqueFailure/
  end

  it "should return a 404 if a key is set and not specified" do
    CepaHealth.register("VeryUniqueTestIFear") { true }
    CepaHealth.key = 'stone'
    code, headers, body = get("/healthy.html")
    code.should == 404
    body.should == ""
  end

  it "should return successful if a key is set and specified" do
    CepaHealth.register("VeryUniqueTestIFear") { true }
    CepaHealth.key = 'stone'
    code, headers, body = get("/healthy.html", 'QUERY_STRING' => 'key=stone')
    code.should == 200
    body.should =~ /VeryUniqueTestIFear/
  end

  it "should filter responses if they have different levels" do
    CepaHealth.register("error1", "error") { false }
    CepaHealth.register("error2", "error") { false }
    CepaHealth.register("warn1", "warn") { true }
    CepaHealth.register("warn2", "warn") { true }
    CepaHealth.key = 'stone'

    code, headers, body = get("/healthy.txt", 'QUERY_STRING' => 'key=stone')
    code.should == 500
    body.should =~ /error1/
    body.should =~ /warn1/

    code, headers, body = get("/healthy.txt", 'QUERY_STRING' => 'key=stone&filters=error,warn')
    code.should == 500
    body.should =~ /error1/
    body.should =~ /warn1/

    code, headers, body = get("/healthy.txt", 'QUERY_STRING' => 'key=stone&filters=error,other2')
    code.should == 500
    body.should =~ /error1/
    body.should_not =~ /warn1/

    code, headers, body = get("/healthy.txt", 'QUERY_STRING' => 'key=stone&filters=warn')
    code.should == 200
    body.should_not =~ /error1/
    body.should =~ /warn1/
  end

  protected

  def get(url, opts = {})
    code, headers, lint = rackapp.call(Rack::MockRequest.env_for(url, opts))
    body = ""; lint.each { |v| body << v.to_s }
    [code, headers, body]
  end

end
# describe Rack::Health do
#   def env(url='/', *args)
#     Rack::MockRequest.env_for(url, *args)
#   end

#   let(:base_app) do
#     lambda do |env|
#       [200, {'Content-Type' => 'text/plain'}, ["I'm base_app"]]
#     end
#   end
#   let(:app) { Rack::Lint.new Rack::Health.new(base_app, rack_health_options) }
#   let(:rack_health_options) { {} }
#   let(:status) { subject[0] }
#   let(:body) { str = ''; subject[2].each {|s| str += s }; str }

#   describe 'with default options' do
#     let(:rack_health_options) { {} }

#     describe '/' do
#       subject { app.call env('/') }

#       it { status.should == 200 }
#       it { body.should == "I'm base_app" }
#     end

#     describe '/rack_health' do
#       subject { app.call env('/rack_health') }

#       it { status.should == 200 }
#       it { body.should == 'Rack::Health says "healthy"' }
#     end
#   end

#   describe 'with :sick_if' do
#     subject { app.call env('/rack_health') }

#     describe '== lambda { true }' do
#       let(:rack_health_options) { { :sick_if => lambda { true } } }

#       it { status.should == 503 }
#       it { body.should == 'Rack::Health says "sick"' }
#     end

#     describe '== lambda { false }' do
#       let(:rack_health_options) { { :sick_if => lambda { false } } }

#       it { status.should == 200 }
#       it { body.should == 'Rack::Health says "healthy"' }
#     end
#   end

#   describe 'with :status' do
#     let(:status_proc) { lambda {|healthy| healthy ? 202 : 404 } }
#     subject { app.call env('/rack_health') }

#     context 'healthy' do
#       let(:rack_health_options) { { :sick_if => lambda { false }, :status => status_proc } }

#       it { status.should == 202 }
#       it { body.should == 'Rack::Health says "healthy"' }
#     end

#     context 'sick' do
#       let(:rack_health_options) { { :sick_if => lambda { true }, :status => status_proc } }

#       it { status.should == 404 }
#       it { body.should == 'Rack::Health says "sick"' }
#     end
#   end

#   describe 'with :body' do
#     let(:body_proc) { lambda {|healthy| healthy ? 'fine' : 'bad' } }
#     subject { app.call env('/rack_health') }

#     context 'healthy' do
#       let(:rack_health_options) { { :sick_if => lambda { false }, :body => body_proc } }

#       it { status.should == 200 }
#       it { body.should == 'fine' }
#     end

#     context 'sick' do
#       let(:rack_health_options) { { :sick_if => lambda { true }, :body => body_proc } }

#       it { status.should == 503 }
#       it { body.should == 'bad' }
#     end
#   end

#   describe 'with :path' do
#     subject { app.call env('/how_are_you') }
#     let(:rack_health_options) { { :path => '/how_are_you' } }

#     it { status.should == 200 }
#     it { body.should == 'Rack::Health says "healthy"' }
#   end
# end
