module Jobber
  # class used by almost all Jobber class that holds the configuration for one jobber worker.
  # singleton through Jobber.config
  #
  # initialize the configuration by
  #   Jobber.configure do
  #     environment :production
  #     beanstalk 'yourdomain.com:11300'
  #     [...]
  #   end
  class Config
    # initializes a Jobber::Config instance with default settings
    def initialize
      @mappings = {}
      @role = :jobber
      @tube_name = 'jobber'

      #the default beanstalk address
      @uri = 'localhost:11300'

      @environment = :development
      @mongo = YAML.load(<<-YAML)
        development:
          sessions:
            default:
              database: jobber_development
              hosts:
                - localhost:27017
        test:
          sessions:
            default:
              database: jobber_test
              hosts:
                - localhost:27017
        production:
          sessions:
            default:
              database: jobber
              hosts:
                - localhost:27017
      YAML
    end

    # sets the environment to be used for this worker instance.
    # used to access different mongo databases for :test, :development and :production
    #
    # @example
    #   environment :test
    #
    # @param [Symbol] env
    def environment(env)
      raise "unknown environment" unless [:production, :test, :development].include?(env)
      @environment = env
    end

    # use this method to provide a custom mongo settings hash that differs from the default.
    #
    # @example
    #   mongo_settings(<<-YAML)
    #     production:
    #       sessions:
    #         default:
    #           database: jobber
    #           hosts:
    #             - localhost:27017
    #   YAML
    #
    # @param [YAML] yaml the mongo configuration YAML
    def mongo_settings(yaml)
      @mongo = YAML.load(yaml)
    end

    # setter to define your beanstalk server address to be used
    #
    # @example
    #   beanstalk("yourdomain.com:11300")
    #
    # @param [String] uri
    def beanstalk(uri)
      @uri = uri
    end

    # setter to define the role of a jobber worker instance.
    # could be :jobber, :participant or :listener
    #
    # @example
    #   has_role :jobber
    # @example
    #   has_role :participant, as: :gateway
    # @example
    #   has_role :listener, as: :platform
    #
    # @param [Symbol] role
    # @param [Hash] opts
    # @option opts [Symbol] :as
    def has_role(role, opts = {})
      @role = role
      @tube_name = opts[:as] if opts[:as]
    end

    # setter to define a job for :jobber instances.
    #
    # @example
    #   job 'make_coffee', creates: Jobs::MakeCoffee
    #
    # @param [String] name (the subject of job instances)
    # @param [hash] opts
    # @option opts [Class] :creates
    def job(name, opts = {})
      @mappings.update(name => opts[:creates])
    end

    # setter to define participant tasks.
    #
    # @example
    #   works on: 'file_outgest', with: Participants::FileOutgest
    #
    # @param [Hash] opts
    # @option opts [String] :on
    # @option opts [Class] :with
    def works(opts = {})
      @mappings.update(opts[:on] => opts[:with])
    end

    # setter to define listener tasks.
    #
    # @example
    #   listens on: 'make_coffee', with: Listeners::WaitForCoffee
    #
    # @param [Hash] opts
    # @option opts [String] :on
    # @option opts [Class] :with
    def listens(opts = {})
      @mappings.update(opts[:on] => opts[:with])
    end

    # getter to return the beanstalk address to be uses
    # @return [String] the beanstalk server address
    def uri
      @uri
    end

    # getter to return the mongo settings to be used
    # this is fetched on intialization after Jobber.configure has been called
    # @return [Hash] the mongo configuration hash
    def mongo
      @mongo[@environment.to_s]
    end

    # getter to return the tube_name used for this jobber worker instance.
    # this is the tube this a jobber worker instance is listening to for messages.
    # @return [String] the beanstalk tube name
    def tube_name
      @tube_name
    end

    # getter to return the role for this jobber worker instance.
    # could be :jobber, :participant or :listener
    def role
      @role
    end

    # getter to return a Class that has been registered in the current worker instance
    # using {#job}, {#works} or {#listens}
    #
    # @example
    #   Jobber.config.klass_for('make_coffee')
    #   => Jobs::MakeCoffee
    #
    # @return [Class] the registered Class
    def klass_for(name)
      @mappings[name]
    end
  end
end
