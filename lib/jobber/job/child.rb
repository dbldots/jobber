module Jobber
  module Job
    class Child < Base
      field :data,      type: Hash

      embedded_in :master, class_name: "Jobber::Job::Master"
      #recursively_embeds_many # TODO future

      state_machine initial: :new do
        after_transition to: :success, do: :proceed_on_master
        after_transition to: :errored, do: :error_on_master
      end

      protected
      # callback to be executed when child job has errored.
      # sets the master job to :errored as well
      def error_on_master
        master.error!(self.message)
      end

      # callback to be executed when child job is done.
      # continues the work on its master job.
      def proceed_on_master
        master.proceed!
      end
    end
  end
end
