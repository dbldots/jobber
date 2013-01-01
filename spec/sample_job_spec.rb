require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MakeCoffee < Jobber::Job::Master
  job_name :make_coffee

  state_machine do
    after_transition :to => :warming_up, :do => :heat
    event :proceed do
      transition :to => :warming_up, :unless => :machine_is_hot?
      transition :to => :coffee_ready
    end
  end

  attr_accessor :hot
  def machine_is_hot?; !!hot; end

  def heat
    self.hot = true
    proceed!
  end
end

describe "MakeCoffee" do
  context "Job basic functionality" do
    it "sets the job name from job definition" do
      job = MakeCoffee.create(:orderer => :human)
      job.new_record?.should be_false
      job.subject.should == "make_coffee"
    end

    it "returns the orderer of the job" do
      job = MakeCoffee.new(:orderer => :human)
      job.orderer.should == "human"
    end
  end

  context "workflow" do
    it "'s initial state is 'new'" do
      job = MakeCoffee.new(:orderer => :human)
      job.state.should == "new"
    end

    it "should give out a coffee immediately" do
      job = MakeCoffee.new(:orderer => :human)
      job.hot = true
      job.should_not_receive(:heat)
      job.submit!
      job.state.should == "coffee_ready"
    end

    it "should heat before giving out the coffee" do
      job = MakeCoffee.new(:orderer => :human)
      job.stub!(:heat).and_return(false)
      job.submit!
      job.state.should == "warming_up"

      job.unstub!(:heat)
      job.heat
      job.state.should == "coffee_ready"
    end
  end
end
