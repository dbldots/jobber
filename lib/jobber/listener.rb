module Jobber
  # @abstract Subclass and override {#got_response!} and {#got_status!}
  #   to implement a jobber listener
  class Listener
    attr_accessor :message
    def initialize(message)
      if !message.is_a?(Jobber::Message::Response) && !message.is_a?(Jobber::Message::Status)
        raise "message must be of type Jobber::Message::Response or Jobber::Message::Status"
      end
      self.message = message
    end

    # called by worker if message is a Jobber::Message::Response
    def got_response!
      raise "has to be implemented in concrete Listener"
    end

    # called by worker if message is a Jobber::Message::Status
    def got_status!
      raise "has to be implemented in concrete Listener"
    end
  end
end
