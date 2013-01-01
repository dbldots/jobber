require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Jobber::Message" do

  context "validation" do
    it "should be invalid" do
      msg = FactoryGirl.build(:message, :subject => nil)
      msg.valid?.should be_false
    end

    it "should be valid" do
      msg = FactoryGirl.build(:message)
      msg.valid?.should be_true
    end
  end

  context "serialization" do

    it "generates proper json" do
      hsh = { :foo => 'bar' }
      msg = Jobber::Message.new(hsh)
      msg.to_json.should == hsh.to_json
    end

    it "raises an error if json doesn't contain proper type" do
      json = { :type => :invalid }.to_json
      expect { Jobber::Message.from_json(json) }.to raise_error
    end

    it "returns a request message" do
      json = { :type => :request }.to_json
      msg = Jobber::Message.from_json(json)
      msg.class.should == Jobber::Message::Request
    end

    it "returns a response message with result `:ok`" do
      json = { :type => :response, :result => :ok }.to_json
      msg = Jobber::Message.from_json(json)
      msg.class.should == Jobber::Message::Response
      msg.ok?.should be_true
    end

    it "returns a status message" do
      json = { :type => :status }.to_json
      msg = Jobber::Message.from_json(json)
      msg.class.should == Jobber::Message::Status
    end
  end

  describe "Jobber::Message::Request" do

    it "'s type should be a request" do
      msg = Jobber::Message::Request.new
      msg.type.should == :request
    end

    it "returns the job" do
      job = FactoryGirl.create(:job_master)
      msg = Jobber::Message::Request.from_job(job)
      msg.job.should == job
    end
  end

  describe "Jobber::Message::Response" do
    it "'s type should be a response" do
      msg = Jobber::Message::Response.new
      msg.type.should == :response
    end

    it "returns the job" do
      job = FactoryGirl.create(:job_master)
      json = { :type => :response, :result => :ok, :job => { :uuid => job.uuid } }.to_json
      msg = Jobber::Message.from_json(json)
      msg.job.should == job
    end

    it "'s result depends on the job's state" do
      job = FactoryGirl.build(:job_master) # new job, not succeeded
      msg = Jobber::Message::Response.from_job(job)
      msg.ok?.should be_false

      job = FactoryGirl.build(:succeeded_job_master)
      msg = Jobber::Message::Response.from_job(job)
      msg.ok?.should be_true
    end
  end

  describe "Jobber::Message::Status" do
    it "'s type should be a status" do
      msg = Jobber::Message::Status.new
      msg.type.should == :status
    end

    it "contains the job's state" do
      job = FactoryGirl.build(:job_master)
      msg = Jobber::Message::Status.from_job(job)
      msg.status.should == job.state
    end
  end
end
