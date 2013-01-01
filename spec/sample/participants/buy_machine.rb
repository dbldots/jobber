module Participants
  class BuyMachine < Jobber::Participant

    def work!
      # deliver machine...
      # then
      response.result = :ok
      respond!
    end
  end
end
