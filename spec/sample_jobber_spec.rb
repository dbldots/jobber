require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Jobber::Worker" do

  context "jobber worker" do
    before(:each) do
      mock_stalker
      @worker = Jobber::Worker.new File.join(File.expand_path(File.dirname(__FILE__)), "sample/jobber.rb")
    end

    it "'s classes should be defined" do
      defined?(Jobs::MakeCoffee).should be_present
    end

    it "'s mapping should be available" do
      Jobber.config.klass_for('make_coffee').should == Jobs::MakeCoffee
    end

    it "should create a new job" do
      assert_difference "Jobber::Job::Master.count", 1 do
        @worker.process_message(build_coffee_message)
      end
    end

    it "sends a 'buy_machine' subjob to the 'machine_manufacturer' first and finishes the job after the machine was bought" do
      Jobs::MakeCoffee.any_instance.stub(:machine?).and_return(false)

      StalkerMock.any_instance.should_receive(:put).twice # job + child job

      message = build_coffee_message
      assert_difference "Jobber::Job::Master.count", 1 do
        @worker.process_message(message)
      end
      job = Jobber::Job::Master.last
      job.children.size.should == 1
      job.children.first.state.should == "pending"

      Jobs::MakeCoffee.any_instance.stub(:machine?).and_return(true)
      job.children.first.proceed! # proceeds the master job as well
      job.reload.children.first.state.should == "success"
      job.state.should == "success"
    end
  end

  def build_coffee_message
    Jobber::Message::Request.new(
      :sender => 'human',
      :recipient => 'jobber',
      :subject => 'make_coffee',
      :data => { :with_love => true }
    )
  end
end
