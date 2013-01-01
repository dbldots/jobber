module Jobber
  # class that handles the processing of incoming messages
  class Worker
    # constructor. called from the executable jobber-worker when starting
    # a jobber worker instance. expects a file path as one and only argument.
    # this file must be a .rb file containing a Jobber.configure block
    # the Jobber::Worker connects to beanstalk via Jobber::Stalker and registers
    # itself to process incoming messages.
    #
    # @example
    #   Jobber::Worker.new("path/to/config.rb")
    #
    # @param [String] config
    #
    # @return [Jobber::Worker] the instance
    
    def initialize(config)
      load(config)

      @stalker = Stalker.instance_for(Jobber.config.tube_name)

      @stalker.register Proc.new { |message|
        process_message(message)
      }
    end

    # this method handles the further processing on messages.
    # depending on the jobber worker instance role it creates a
    # - JobberWorkerUnit
    # - ParticipantWorkerUnit or
    # - ListenerWorkerUnit
    #
    # for each incoming message
    #
    # @example
    #   process_message(<Jobber::Message>)
    #
    # @param [Jobber::Message] message
    def process_message(message)
      case Jobber.config.role
      when :jobber      then JobberWorkerUnit.new(message)
      when :participant then ParticipantWorkerUnit.new(message)
      when :listener    then ListenerWorkerUnit.new(message)
      end
    end
  end

  class WorkerUnit
    attr_accessor :message
    def initialize(message)
      self.message = message
      work!
    end

    def klass
      Jobber.config.klass_for(message.subject)
    end

    def work!
      case message
      when Message::Request   then process_request
      when Message::Response  then process_response
      when Message::Status    then process_status
      end
    end

    protected

    def process_request
      raise "unable to process 'request' for #{Jobber.config.role}"
    end

    def process_response
      raise "unable to process 'response' for #{Jobber.config.role}"
    end

    def process_status
      raise "unable to process 'status' for #{Jobber.config.role}"
    end
  end

  class JobberWorkerUnit < WorkerUnit
    # creates a new job and submits the job
    def process_request
      job = klass.create!(uuid: message.job_uuid, orderer: message.sender, data: message.data)
      job.submit!
    end

    # this method is called once a remote job is done.
    # updates the job data and errors/succeeds the job depending on
    # the response result.
    def process_response
      job = message.job
      job.data = message.data
      job.message = message.message

      if message.ok?
        job.proceed!
      else
        job.error!
      end
    end
  end

  class ParticipantWorkerUnit < WorkerUnit
    # method that is called in a participant worker instance once it gets
    # a new task to work on. initializes the Participant implementation and
    # triggers the work! method of it.
    def process_request
      concrete = klass.new(message)
      concrete.work!
    end
  end

  class ListenerWorkerUnit < WorkerUnit
    def process_response
      concrete = klass.new(message)
      concrete.got_response!
    end

    def process_status
      concrete = klass.new(message)
      concrete.got_status!
    end
  end
end
