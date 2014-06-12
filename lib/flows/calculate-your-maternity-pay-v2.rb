status :draft
satisfies_need "101011"

# Question 1
date_question :when_is_your_baby_due? do
  save_input_as :due_date
  calculate :calculator do
    Calculators::MaternityBenefitsCalculatorV2.new(Date.parse(responses.last))
  end

  calculate :expected_week_of_childbirth do
    calculator.expected_week
  end
  calculate :qualifying_week do
    calculator.qualifying_week
  end
  calculate :start_of_qualifying_week do
    qualifying_week.first
  end
  calculate :start_of_test_period do
    calculator.test_period.first
  end
  calculate :end_of_test_period do
    calculator.test_period.last
  end
  calculate :twenty_six_weeks_before_qualifying_week do
    calculator.employment_start
  end
  calculate :smp_lel do
    calculator.smp_lel
  end

  calculate :smp_rate do
    calculator.smp_rate
  end

  calculate :ma_rate do
    calculator.ma_rate
  end

  calculate :eleven_weeks do
    calculator.eleven_weeks
  end

  next_node :are_you_employed?
end

# Question 2
multiple_choice :are_you_employed? do
  option :yes
  option :no

  next_node_if(:have_you_helped_partner_self_employed?) do |response|
    response == 'no' && due_date >= ("2014-07-27")
  end
  next_node_if(:will_you_work_at_least_26_weeks_during_test_period?) do |response|
    response == 'no' && due_date < ("2014-07-27")
  end
  next_node(:did_you_start_26_weeks_before_qualifying_week?)
end

# Question 3
multiple_choice :did_you_start_26_weeks_before_qualifying_week? do
  option :yes
  option :no

  # We assume that if they are employed, that means they are
  # employed *today* and if today is after the start of the qualifying
  # week we can skip that question
  next_node_if(:how_much_do_you_earn?) do |response|
    response == 'yes' && Date.today >= qualifying_week.first
  end
  next_node_if(:will_you_still_be_employed_in_qualifying_week?) do |response|
    response == 'yes' && Date.today < qualifying_week.first
  end

  # If they weren't employed 26 weeks before qualifying week, there's no
  # way they can qualify for SMP, so consider MA instead.
  next_node(:will_you_work_at_least_26_weeks_during_test_period?)
end

# Question 4
salary_question :how_much_do_you_earn? do
  next_node_calculation(:weekly_salary_90) do |salary|
    Money.new(salary.per_week * 0.9)
  end
  # Outcome 2
  next_node_if(:smp_from_employer) { |salary| salary.per_week >= smp_LEL }
  # Outcome 3
  next_node_if(:you_qualify_for_maternity_allowance) do |salary|
    salary.per_week >= 30 && salary.per_week < smp_LEL
  end
  # Outcome 1
  next_node(:nothing_maybe_benefits)

  calculate :eligible_amount do
    weekly_salary_90
  end

  calculate :smp_6_weeks do
    weekly_salary_90
  end

  calculate :smp_33_weeks do
    smp_rate > smp_6_weeks.to_f ? smp_6_weeks : Money.new(smp_rate)
  end

  calculate :smp_total do
    Money.new(smp_6_weeks.to_f * 6 + smp_33_weeks.to_f * 33)
  end

  calculate :ma_rate do
    # either ma_rate or weekly_salary_90, whichever is lower
    calculator.ma_rate > weekly_salary_90.to_f ? weekly_salary_90 : Money.new(calculator.ma_rate)
  end

  calculate :ma_payable do
    Money.new(ma_rate.to_f * 39)
  end
end

# Question 5
multiple_choice :will_you_still_be_employed_in_qualifying_week? do
  option yes: :how_much_do_you_earn?
  option no: :will_you_work_at_least_26_weeks_during_test_period?
end

# Note this is only reached for 'employed' people who
# have worked 26 weeks for the same employer
# 135.45 is standard weekly rate. This may change
# 107 is the lower earnings limit. This may change

# Question 6
multiple_choice :will_you_work_at_least_26_weeks_during_test_period? do
  option yes: :how_much_did_you_earn_between?
  option no: :nothing_maybe_benefits # Outcome 1
end

# Question 7
salary_question :how_much_did_you_earn_between? do
  next_node_calculation(:weekly_salary_90) do |earnings|
    Money.new(earnings.per_week * 0.9)
  end

  # Outcome 3
  next_node_if(:you_qualify_for_maternity_allowance) do |earnings|
    earnings.per_week >= 30.0
  end

  # Outcome 1
  next_node(:nothing_maybe_benefits)

  calculate :eligible_amount do
    weekly_salary_90
  end

  calculate :ma_rate do
    # either ma_rate or weekly_salary_90, whichever is lower
    calculator.ma_rate > weekly_salary_90.to_f ? weekly_salary_90 : Money.new(calculator.ma_rate)
  end

  calculate :ma_payable do
    Money.new(ma_rate * 39)
  end
end

# Question 8
multiple_choice :have_you_helped_partner_self_employed? do
  option yes: :have_you_been_paid_for_helping_partner?
  option no: :will_you_work_at_least_26_weeks_during_test_period?
end

# Question 9
multiple_choice :have_you_been_paid_for_helping_partner? do
  option yes: :nothing_maybe_benefits
  option no: :partner_helped_for_more_than_26weeks?
end

# Question 10
multiple_choice :partner_helped_for_more_than_26weeks? do
  option yes: :lower_maternity_allowance
  option no: :nothing_maybe_benefits
end

# Outcome 1
outcome :nothing_maybe_benefits do
  precalculate :extra_help_phrase do
    PhraseList.new(:extra_help)
  end
end

# Outcome 2
outcome :smp_from_employer do
  precalculate :extra_help_phrase do
    PhraseList.new(:extra_help)
  end
end

# Outcome 3
outcome :you_qualify_for_maternity_allowance do
  precalculate :extra_help_phrase do
    PhraseList.new(:extra_help)
  end
end

# Outcome 4
outcome :lower_maternity_allowance do
  precalculate :extra_help_phrase do
    PhraseList.new(:extra_help)
  end

  precalculate :due_date_minus_11_weeks do
    Date.parse(due_date) - 11.weeks
  end
end
