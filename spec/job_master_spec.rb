require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Jobber::Job::Master" do
  context "uuid" do
    it "generates a uuid before validation" do
      job = FactoryGirl.build(:job_master)
      job.should be_valid
      job.uuid.should be_present
    end

    it "is an invalid uuid" do
      job = FactoryGirl.build(:job_master, :uuid => "invalid")
      job.should_not be_valid
    end

    it "has a valid predefined uuid" do
      uuid = UUID.new.generate(:compact)
      job = FactoryGirl.build(:job_master, :uuid => uuid)
      job.should be_valid
      job.uuid.should equal(uuid)
    end
  end

  context "state_machine" do
    it "errors the parent job as well" do
      mock_stalker
      job = FactoryGirl.create(:job_master)
      child = FactoryGirl.build(:job_child)
      job.children << child

      child.error!
      job.reload
      child.state.should == "errored"
      job.state.should == "errored"
    end
  end

  context "nested jobs" do
    it "is saved together with nested job" do
      job = FactoryGirl.create(:job_master)
      job.new_record?.should be_false

      child = FactoryGirl.build(:job_child)
      job.children << child
      job.reload.children.should include child
    end

    it "should save an uuid for the child job as well" do
      job = FactoryGirl.create(:job_master)
      job.children << FactoryGirl.build(:job_child)
      job.children.first.uuid.should be_present
    end

    it "finds a job by uuid" do
      job = FactoryGirl.create(:job_master)
      Jobber::Job::Base.find_job(job.uuid).should == job
    end

    it "finds an embedded child job by uuid" do
      job = FactoryGirl.create(:job_master)
      child = FactoryGirl.build(:job_child)
      job.children << child

      Jobber::Job::Base.find_job(child.uuid).should == child
    end
  end
end
