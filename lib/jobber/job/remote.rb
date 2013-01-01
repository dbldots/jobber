module Jobber
  module Job
    class Remote < Child
      field :participant, type: String

      state_machine do
        before_transition to: :pending, do: :send_message!

        event :proceed do
          transition new: :pending
          transition pending: :success
        end
      end

      # sends the request to the remote participant
      # that should process this child job
      def send_message!
        msg = Message::Request.from_job(self)
        msg.send!
      end
    end
  end
end
