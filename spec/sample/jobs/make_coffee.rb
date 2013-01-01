module Jobs
  class MakeCoffee < ::Jobber::Job::Master
    job_name :make_coffee
    # participants: machine_manufacturer, machine_service, beans_supplier
    # orderer: human

    state_machine do
      # `proceed` is the main required event that is used by jobber. of course,
      # you may want to define more events depending on the complexity of
      # your job definition. have a look at 
      # https://github.com/pluginaweek/state_machine
      #
      # jobber calls a method 'on_<new_state_name>' if defined after each transition
      event :proceed do
        transition :to => :buying_machine, :unless => :machine?
        transition :to => :fixing_machine, :if => :machine_error?
        transition :to => :buying_beans, :unless => :beans?
        transition :to => :pouring_coffee
      end

      event :done do
        transition :to => :success
      end
    end

    def machine?
      true
    end

    def machine_error?
      false
    end

    def beans?
      true
    end

    def on_buying_machine
      create_remote_job(
        'machine_manufacturer',
        'buy_machine',
        {
          :model => 'jura impressa s90'
        }).submit!
    end

    def on_fixing_machine
      create_remote_job(
        'machine_service',
        'fix_machine',
        {
          :model => 'jura impressa s90', :when => 'ASAP'
        }).submit!
    end

    def on_buying_beans
      create_remote_job(
        'beans_supplier',
        'buy_beans',
        {
          :amount => "1kg"
        }).submit!
    end

    def on_pouring_coffee
      done!
    end
  end
end
