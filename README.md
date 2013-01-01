# jobber

## about

jobber is a library that aims to provide a simple way to define distributed jobs. a job workflow is defined using the great workflow gem `state_machine`.

the idea to implement jobber was to decouple services that are working on distributed tasks together. each of the participants should have a jobber worker running that is listening to incoming messages to process.

in a typical setup you would have a minimum of three workers running

* the orderer (owner) of jobs has a `listener worker` running to process the responses/status messages
* the main `jobber worker` where the actual job implementations are loaded
* at least one more `participant worker` that works on child jobs in order to get the whole thing done

in addition a beanstalk server needs to run somewhere accessible to all of the workers. of course, the beanstalk server and the worker may run on the same or on different machines.

using jobber, an orderer of jobs **only has to know about**

* the job name, e.g. `make_coffee`
* the data required to get the job done. e.g. `{ with_milk: true }`

it **DOESN'T have to know about** the participants that are involved to get the job done, nor does it need to know where the participants are or how they work.

there are no side-effects on any participant if one of them goes down (except for the job not getting done).

because jobber is using the `Versioning` module of mongoid there is always the full process history of a job available in the db.


## requirements

jobber is built on top these gems:

* mongoid
* state_machine
* beneater (beanstalk client)
* daemons

as mongoid requires ruby 1.9.3 (or newer), jobber won't work with previous ruby versions as well.


## usage

have a look at the specs and the sample job implementation you can find in `spec/sample`.

assuming you have a jobber worker instance running with a job implementation registered with the name `make_coffee` you can submit a job using

	require 'jobber'
	require 'uuid'
	
	message = Jobber::Message::Request.new(:subject => 'make_coffee')
	# generate a uuid to be able to identify the job response later on
	message.job_uuid = UUID.new.generate(:compact)
	message.sender = 'human'
	Jobber::Stalker.instance_for(:jobber).put(message)
			
once the job is done, a `Jobber::Message::Response` will be sent to a listener worker that handles messages for `human`.

## todo

* a flag like `trigger_status_updates(true)` in a job class implementation should inform the orderer of the job about each status change of the job
* provide functionality to completely reset a job and start from the beginning
* worker script should optionally take an additional argument `worker-number` so that multiple workers with the same role can run in parallel
* generic job data validation mechanism


## contributing to jobber
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## copyright

copyright (c) 2012 johannes-kostas götzinger. See LICENSE.txt for
further details.

