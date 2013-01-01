require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class SampleJob < Jobber::Job::Master; end;
class SampleParticipant < Jobber::Participant; end
class SampleListener < Jobber::Listener; end

describe "Jobber::Config" do
  it "'s instance should be available through Jobber module" do
    Jobber.config.is_a?(Jobber::Config).should be_true
  end

  context "settings" do
    context "defaults" do
      it "'s defaults are set" do
        config = Jobber::Config.new
        config.mongo.should be_present
        config.uri.should be_present
        config.tube_name.should be_present
        config.role.should be_present
      end
    end

    context "mongo configuration" do
      it "should use the provided mongo configuration" do
        Mongoid::Config.stub(:load_configuration).and_return(true)

        Jobber.configure do
          environment :test
          mongo_settings <<-YAML
            production: none
            test: yay
          YAML
        end

        Jobber.config.mongo.should == 'yay'
      end
    end

    context "with role :jobber" do
      before(:each) do
        Jobber.configure do
          environment :test
          has_role :jobber
          job 'make_coffee', creates: SampleJob
        end
      end

      it "should habe the tube_name 'jobber'" do
        Jobber.config.tube_name == 'jobber'
      end

      it "should have the :jobber role" do
        Jobber.config.role.should == :jobber
      end

      it "should return the SampleJob klass" do
        Jobber.config.klass_for('make_coffee').should == SampleJob
      end
    end

    context "with role :participant" do
      before(:each) do
        Jobber.configure do
          environment :test
          has_role :participant, :as => 'foo'
          works on: 'foo', with: SampleParticipant
        end
      end

      it "should habe the tube_name 'foo'" do
        Jobber.config.tube_name == 'foo'
      end

      it "should have the :participant role" do
        Jobber.config.role.should == :participant
      end

      it "should return the SampleParticipant klass" do
        Jobber.config.klass_for('foo').should == SampleParticipant
      end
    end

    context "with role :listener" do
      before(:each) do
        Jobber.configure do
          environment :test
          has_role :listener, :as => 'platform'
          listens on: 'bar', with: SampleListener
        end
      end

      it "should habe the tube_name 'platform'" do
        Jobber.config.tube_name == 'platform'
      end

      it "should have the :listener role" do
        Jobber.config.role.should == :listener
      end

      it "should return the SampleListener klass" do
        Jobber.config.klass_for('bar').should == SampleListener
      end
    end
  end
end
