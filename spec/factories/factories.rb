FactoryGirl.define do
  factory :job_master, class: Jobber::Job::Master do
    orderer "foo"
    subject "just_a_job"
  end

  factory :succeeded_job_master, class: Jobber::Job::Master do
    orderer "foo"
    subject "just_a_job"
    state   "success"
  end

  factory :job_child, class: Jobber::Job::Child do
    orderer "bar"
    subject "just_a_child_job"
  end

  factory :message, class: Jobber::Message do
    sender    "platform"
    recipient "gateway"
    subject   "job_name"
  end
end
