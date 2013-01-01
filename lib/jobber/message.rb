require 'yajl'

module Jobber
  # a basic hash wrapper class to contain message data with some useful 
  # setters and getters as well as json (de)serialization.
  #
  # a message requires 'sender', 'recipient' and 'subject' to be valid.
  # @see {#valid?}
  class Message

    # @!attribute [r] errors contains errors if the message is invalid
    attr_reader :errors

    # constructor.
    #
    # @example
    #   initialize(type: 'request', data: { foo: 'bar' })
    #
    # @param [Hash] raw_data ({})
    def initialize(raw_data = {})
      @errors = []
      @raw_data = raw_data
    end

    # subject setter
    def subject=(subject)
      @raw_data[:subject] = subject.to_s
    end

    # subject getter
    def subject
      @raw_data[:subject]
    end

    # sender setter
    def sender=(sender)
      @raw_data[:sender] = sender.to_s
    end

    # sender getter
    def sender
      @raw_data[:sender]
    end

    # recipient setter
    def recipient=(recipient)
      @raw_data[:recipient] = recipient.to_s
    end

    # recipient getter
    def recipient
      @raw_data[:recipient]
    end

    # message setter
    def message=(message)
      @raw_data[:message] = message
    end

    # message getter
    def message
      @raw_data[:subject]
    end

    # data setter
    def data=(data)
      @raw_data[:data] = data
    end

    # data getter
    def data
      @raw_data[:data]
    end

    # raw_data getter
    # @return [Hash] the Hash containing the whole message
    def raw_data
      @raw_data
    end

    # type getter
    # @return [Symbol] :request, :response, :status
    def type
      @raw_data[:type].to_sym
    end

    # method to serialize this message to JSON
    # @return [String] json
    def to_json
      Yajl::Encoder.encode(@raw_data)
    end

    # helper method to return a job this message is referenced to by uuid.
    # @return [Jobber::Job, nil] the job if uuid given and job could be found
    def job
      job_uuid && Jobber::Job::Base.find_job(job_uuid)
    end

    # job uuid setter.
    # sets raw_data[:job][:uuid]
    def job_uuid=(uuid)
      @raw_data[:job] ||= {}
      @raw_data[:job].update(uuid: uuid)
    end

    # job uuid getter
    def job_uuid
      @raw_data[:job] && @raw_data[:job][:uuid]
    end

    # deserializes a message from json string
    # @param [String] json
    # @return [Jobber::Message] the deserialized message
    def self.from_json(json)
      raw_data = Yajl::Parser.parse(json, symbolize_keys: true)

      case raw_data[:type]
      when "request"    then Message::Request.new(raw_data)
      when "response"   then Message::Response.new(raw_data)
      when "status"     then Message::Status.new(raw_data)
      else raise "unsupported type `#{type}`"
      end
    end

    # checks if this message is valid.
    # if message is invalid, error messages can be accessed through {#errors} afterwards.
    #
    # @return [true, false]
    def valid?
      @errors.push("sender must be present")    if sender.blank?
      @errors.push("recipient must be present") if recipient.blank?
      @errors.push("subject must be present")   if subject.blank?

      @errors.empty?
    end

    # method to actually send this message to the given recipient
    def send!
      return false unless valid?
      Stalker.instance_for(self.recipient).put(self)
    end
  end

  class Message::Request < Message
    def initialize(raw_data = {})
      super
      @raw_data[:type] = "request"
    end

    def self.from_job(job, data = nil)
      Jobber::Message::Request.new({
        job: { uuid: job.uuid },
        data: data || job.data,
        subject: job.subject,
        sender: :jobber,
        recipient: job.is_a?(Jobber::Job::Remote) ? job.participant : nil })
    end
  end

  class Message::Status < Message
    def initialize(raw_data = {})
      super
      @raw_data[:type] = "status"
    end

    def status=(status)
      @raw_data[:status] = status.to_s
    end

    def status
      @raw_data[:status]
    end

    def self.from_job(job)
      Jobber::Message::Status.new({
        job: { uuid: job.uuid },
        status: job.state })
    end
  end

  class Message::Response < Message
    def initialize(raw_data = {})
      super
      @raw_data[:type] = "response"
    end

    def result=(result)
      result = result.to_s
      raise "unsupported result `#{result}`" unless %w(ok error).include?(result)
      @raw_data[:result] = result
    end

    def result
      @raw_data[:result]
    end

    def ok?
      result == "ok"
    end

    def error?
      result == "error"
    end

    def self.from_request(request)
      Message::Response.new(request.raw_data)
    end

    def self.from_job(job)
      Message::Response.new({
        job: { uuid: job.uuid },
        subject: job.subject,
        result: ( job.state == "success" ? "ok" : "error" ),
        data: job.data })
    end
  end
end
