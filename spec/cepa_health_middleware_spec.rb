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
    app = ->(e) { [200, { 'Content-Type' => 'text/plain; charset=utf-8' }, ["Boom"]] }
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
    CepaHealth.register { ["VeryUniqueTestIFear", true, ""] }
    code, headers, body = get("/healthy.html")
    code.should == 200
    body.should =~ /VeryUniqueTestIFear/
  end

  it "should return a 500 Error for failing probes" do
    CepaHealth.register { ["VeryUniqueTestIFear", true, ""] }
    CepaHealth.register { ["TotallyUniqueFailure", false, ""] }
    code, headers, body = get("/healthy.html")
    code.should == 500
    body.should =~ /TotallyUniqueFailure/
  end

  it "should return a 404 if a key is set and not specified" do
    CepaHealth.register { ["VeryUniqueTestIFear", true, "" ] }
    CepaHealth.key = 'stone'
    code, headers, body = get("/healthy.html")
    code.should == 404
    body.should == ""
  end

  it "should return successful if a key is set and specified" do
    CepaHealth.register { ['VeryUniqueTestIFear', true, "" ] }
    CepaHealth.key = 'stone'
    code, headers, body = get("/healthy.html", 'QUERY_STRING' => 'key=stone')
    code.should == 200
    body.should =~ /VeryUniqueTestIFear/
  end

  it "should filter responses if they have different levels" do
    CepaHealth.register("error") { ['error1', false, ""] }
    CepaHealth.register("error") { ['error2', false, ""] }
    CepaHealth.register("warn") { ['warn1', true, ""] }
    CepaHealth.register("warn") { ['warn2', true, ""] }
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
