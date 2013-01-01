require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Jobber::Worker" do

  context "listener worker" do
    before(:each) do
      mock_stalker
      @worker = Jobber::Worker.new File.join(File.expand_path(File.dirname(__FILE__)), "sample/listener.rb")
    end

    it "'s classes should be defined" do
      defined?(Listeners::WaitForCoffee).should be_present
    end

    it "'s mapping should be available" do
      Jobber.config.klass_for('make_coffee').should == Listeners::WaitForCoffee
    end

    it "should call the got_response method" do
      message = Jobber::Message::Response.from_job(build_coffee_job)
      message.ok?.should be_true

      Listeners::WaitForCoffee.any_instance.should_receive(:got_response!).once
      @worker.process_message(message)
    end

  end

  def build_coffee_job
    FactoryGirl.build(:succeeded_job_master,
      :orderer => 'human',
      :subject => 'make_coffee')
  end

end
