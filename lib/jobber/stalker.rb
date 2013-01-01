module Jobber
  # class that handles the connection to beanstalk
  class Stalker
    # initializer method. should not be initialized directly.
    # use 'instance_for' instead.
    #
    # @example
    #   Stalker.new("platform")
    #   # => <Stalker>
    #
    # @param [String] tube_name
    #
    # @return [Stalker] the instance
    
    def initialize(tube_name)
      @tube_name = tube_name
      @tube = beanstalk.tubes[tube_name]
    end

    # returns a Stalker instance for a jobber worker instance.
    # instances are cached and initialized only once for each end point.
    #
    # @example
    #   instance_for("platform")
    #   # => <Stalker>
    #
    # @param [String] tube_name
    # @return [Stalker] the instance
    
    def self.instance_for(tube_name)
      cache_key = "jobber_#{tube_name}".to_sym
      Thread.current[cache_key] ||= Jobber::Stalker.new(tube_name)
    end

    # sends out a <Message> via beanstalk.
    # converts the message to json before sending.
    #
    # @example
    #   put(message)
    #
    # @param [Message] message
    def put(message)
      message.recipient ||= self.tube_name
      raise "message invalid: #{message.errors}" unless message.valid?
      @tube.put message.to_json
    end

    # registers a callback for incoming messages
    #
    # @example
    #   register Proc.new { |message|
    #     puts message.inspect
    #   }
    #
    # @param [Proc] callback
    def register(callback)
      beanstalk.jobs.register(@tube_name) do |beneater_job|
        message = Message.from_json(beneater_job.body)
        puts message.inspect
        callback.call(message)
      end
      beanstalk.jobs.process!
    end

    private

    # returns a connection to beanstalk by using the Jobber.config settings.
    def beanstalk
      Thread.current[:jobber_beanstalk] ||= Beaneater::Pool.new(Jobber.config.uri)
    end
  end
end
