require 'state_machine'

module Jobber
  module Job
    class Base
      include Mongoid::Document
      include Mongoid::Timestamps

      # when a new job is submitted then the orderer should already know
      # about a unique id to be handle responses properly
      # that's why we include uuid here
      # new jobs should be initialized with an precalculated uuid
      # for child jobs we create the uuid before creation
      include Vidibus::Uuid::Mongoid

      field :data, type: Hash
      field :subject, type: String
      field :orderer, type: String
      field :message, type: String

      validates_presence_of :orderer, :subject

      state_machine initial: :new do
        # to simplify the implementation logic after each transition
        # a method 'on_<new_state>' is called if the method is defined
        after_transition any => any do |job, transition|
          meth = "on_#{transition.to}"
          job.send(meth) if job.respond_to?(meth)
        end

        event :error do
          transition all => :errored
        end

        # this is the event the main workflow should be defined in
        # as proceed! is called by workers.
        # see samples.
        event :proceed do
          # has to be implemented in subclasses
        end
      end

      # method to submit a job
      def submit!
        proceed!
      end

      # call this method to cancel a job and set the state to :errored.
      # an optional error message to be stored may be given.
      #
      # @example
      #   error("shit happens")
      #
      # @param [String] msg (nil)
      #
      def error(msg = nil)
        self.message = msg
        super
      end

      # helper method to find a job or an embedded child job by uuid
      def self.find_job(uuid)
        if job = Master.where(uuid: uuid).first
          return job
        elsif job = Master.where("children.uuid" => uuid).first
          job.children.detect { |child| child.uuid == uuid }
        end
      end
    end
  end
end
