require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Jobber::Worker" do

  context "participant worker" do
    before(:each) do
      mock_stalker
      @worker = Jobber::Worker.new File.join(File.expand_path(File.dirname(__FILE__)), "sample/participant.rb")
    end

    it "'s classes should be defined" do
      defined?(Participants::BuyMachine).should be_present
    end

    it "'s mapping should be available" do
      Jobber.config.klass_for('buy_machine').should == Participants::BuyMachine
    end

    it "should call the work! method" do
      StalkerMock.any_instance.should_receive(:put).once # response

      message = Jobber::Message::Request.new(
        :sender => 'jobber',
        :recipient => 'machine_manufacturer',
        :subject => 'buy_machine',
        :data => {
          :model => 'jura impressa s90'
        }
      )

      Participants::BuyMachine.any_instance.should_receive(:work!).once.and_call_original
      @worker.process_message(message)
    end

  end
end
