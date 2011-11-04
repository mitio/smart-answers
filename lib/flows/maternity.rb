multiple_choice :what_is_your_employment_status? do
  option :employed => :employed_when_is_your_baby_due?
  option :self_employed => :self_employed_when_is_your_baby_due?
  option :unemployed => :nothing_maybe_benefits
end

date_question :employed_when_is_your_baby_due? do
  save_input_as :due_date
  next_node :did_you_start_your_job_on_or_before_start_of_test_period?
end

multiple_choice :did_you_start_your_job_on_or_before_start_of_test_period? do
  calculate :start_of_test_period do
    Date.parse(due_date) - 66.weeks
  end
  option :no => :when_did_you_start_your_job?
  # option :yes => :will_you_be_employed_for_26_weeks_including_qualifying_week?
  option yes: :nothing_maybe_benefits
end

date_question :when_did_you_start_your_job? do
  from { start_of_test_period }
  to { due_date }
  next_node do
    :you_qualify_for_maternity_allowance
  end
end

date_question :self_employed_when_is_your_baby_due? do
  next_node :nothing_maybe_benefits
end

outcome :nothing_maybe_benefits
outcome :you_qualify_for_statutory_maternity_pay
outcome :you_qualify_for_maternity_allowance
