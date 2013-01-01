module Jobber
  # @abstract Subclass and override {#work!}
  #   to implement a jobber participant.
  #   should call {#respond!} when the work is done to return a result to the jobber.
  class Participant

    # @!attribute [rw] message the request message for this participant task.
    attr_accessor :message

    def initialize(message)
      raise "message must be of type Jobber::Message::Request" unless message.is_a?(Jobber::Message::Request)
      self.message = message
    end

    def work!
      raise "has to be implemented in concrete Participant"
    end

    # returns a result (positive or negative depending on the {#response}.result)
    def respond!
      Stalker.instance_for(message.sender).put(response)
    end

    def response
      @response ||= Message::Response.from_request(message)
    end
  end
end
