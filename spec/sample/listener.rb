Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), "listeners/*")).each do |file|
  require file
end

Jobber.configure do
  environment :test
  has_role :listener, as: :human
  listens on: 'make_coffee', with: Listeners::WaitForCoffee
end
