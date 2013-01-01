Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), "participants/*")).each do |file|
  require file
end

Jobber.configure do
  environment :test
  has_role :participant, as: :machine_manufacturer
  works on: 'buy_machine', with: Participants::BuyMachine
end
