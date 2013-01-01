module Jobber
  module Job
    class Master < Base
      include Mongoid::Versioning

      embeds_many :children, class_name: "Jobber::Job::Child"

      before_validation :write_subject

      class << self
        # sets the name of this job as a class variable
        # this job_name will become the subject of the job instances.
        def job_name(name)
          @job_name = name
        end
      end

      # for Master jobs there are three default states
      # - new (defined in Jobber::Job::Base as the initial state of each job)
      # - success
      # - errored
      #
      # when getting to the :success or :error state a Response will be sent to the orderer
      # of the job.
      state_machine do
        after_transition to: :success, do: :return_result
        after_transition to: :errored, do: :return_result
      end

      # helper method for easy creation of remote jobs (child jobs that are passed to remote participants)
      #
      # @example
      #   create_remote_job('gateway', 'file_outgest', { filename: 'new_york_i_love_you.avi' })
      #   # => return value
      #
      # @param [String] participant the name of the remote participant
      # @param [String] subject the job's subject (job_name)
      # @param [Hash] data the job's data Hash
      #
      # @return [Jobber::Job::Remote] description
      def create_remote_job(participant, subject, data = {})
        remote_job = Remote.new(
          subject: subject,
          participant: participant,
          orderer: :jobber,
          data: data)
        self.children << remote_job
        remote_job
      end

      protected

      # writes the job_name into the subject of a new job instance
      def write_subject
        self.subject ||= self.class.instance_variable_get("@job_name")
      end

      # sends a result to the orderer of this job
      # @see Message::Response.from_job
      def return_result
        message = Message::Response.from_job(self)
        Stalker.instance_for(orderer).put(message)
      end

    end
  end
end
