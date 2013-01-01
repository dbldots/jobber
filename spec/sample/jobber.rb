Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), "jobs/*")).each do |file|
  require file
end

Jobber.configure do
  environment :test
  has_role :jobber
  job 'make_coffee',    creates: Jobs::MakeCoffee
  #job 'delivery_order', creates: Jobs::DeliveryOrder

  # or
  #beanstalk '127.0.0.1:11300'
  #has_role :participant, as: :gateway
  #works on: 'file_outgest', with: Worker::FileOutgest

  # or
  #has_role :listener, as: :platform
  #listens on: 'delivery_order', with: Listener::DeliveryOrder
end
