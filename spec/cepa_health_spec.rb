# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.

require 'cepa-health'

describe CepaHealth do

  before(:each) { CepaHealth.clear_probes! }

  it "should register and execute successful probes" do
    standard_setup
    should_be(true, 4)
  end

  it "should register a failure on any unsuccessful probe" do
    standard_setup
    CepaHealth.register("Fail") { false }
    CepaHealth.register("Four") { true }
    should_be(false, 6)
  end

  it "should allow the registration of probes in levels" do
    CepaHealth.register("One") { false }
    CepaHealth.register("Two", "error") { false }
    CepaHealth.register("Three", "warn") { true }
    CepaHealth.register("Four", "warn") { true }
    CepaHealth.register("Five", "warn") { true }
    should_be(false, 5)
    should_be(false, 2, "error")
    should_be(true, 3, "warn")
    should_be(false, 5, %w{error warn other})
  end

  protected

  def should_be(ok, record_length, filters = [])
    r = CepaHealth.execute(*filters)
    r.success?.should == ok
    r.records.length.should == record_length
    r.success?
  end

  def standard_setup
    CepaHealth.register("One") { true }
    CepaHealth.register("Two") { true }
    CepaHealth.register("Three") { record("Three-B", true, "") }    
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
