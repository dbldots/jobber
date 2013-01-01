$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'database_cleaner'
require 'factory_girl'
require 'debugger'
require 'assert_difference'

require 'jobber'

Dir["#{File.dirname(__FILE__)}/mocks/**/*.rb"].each { |f| require f }

FactoryGirl.find_definitions

Jobber.configure do
  environment :test
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.include AssertDifference
 
  config.before(:each) do
    DatabaseCleaner.orm = "mongoid" 
    DatabaseCleaner.strategy = :truncation, { except: %w[ neighborhoods ]}
    DatabaseCleaner.clean
  end
end

def mock_stalker
  Jobber::Stalker.stub(:instance_for).and_return(StalkerMock.new)
end
