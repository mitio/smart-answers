status :published
satisfies_need "100865"

data_query = Calculators::StatePensionTopupDataQuery.new()

#Q1
date_question :dob_age? do
  from { 101.years.ago }
  to { Date.today }

  save_input_as :date_of_birth

  next_node_calculation(:dob) { |response| Date.parse(response) }
  next_node_if(:outcome_age_limit_reached_birth) { (dob < (Date.parse('2015-10-12') - 101.years)) }
  next_node_if(:outcome_pension_age_not_reached) { (dob > Date.parse('1953-04-06')) }
  next_node(:how_much_extra_per_week?)
end

#Q2
money_question :how_much_extra_per_week? do
  save_input_as :money_wanted

  calculate :integer_value do
    money = responses.last.to_f
    if (money % 1 != 0) or (money > 25 or money < 1)
      raise SmartAnswer::InvalidResponse
    end
  end
  next_node :date_of_lump_sum_payment?
end

#Q3
date_question :date_of_lump_sum_payment? do
  from { Date.parse('12 Oct 2015') }
  to { Date.parse('01 April 2017') }

  next_node_calculation(:date_of_payment) { |response| Date.parse(response) }
  next_node_calculation(:age_at_date_of_payment) { date_of_payment.year - dob.year }

  validate { date_of_payment >= Date.parse('2015-10-12') and date_of_payment <= Date.parse('2017-04-01') }

  next_node_if(:outcome_age_limit_reached_payment) { age_at_date_of_payment > 100 }
  next_node(:gender?)
end

#Q4
multiple_choice :gender? do
  option :male
  option :female

  save_input_as :gender

  next_node_if(:outcome_pension_age_not_reached) do |response|
    (response == "male") and (dob > Date.parse('1951-04-06'))
  end
  next_node(:outcome_qualified_for_top_up_calculations)
end

#A1
outcome :outcome_qualified_for_top_up_calculations do

  precalculate :weekly_amount do
    sprintf("%.0f", money_wanted)
  end

  precalculate :rate_at_time_of_paying do
    money = money_wanted.to_f
    total = data_query.age_and_rates(age_at_date_of_payment) * money

    total_money = SmartAnswer::Money.new(total)
  end
end

#A2
outcome :outcome_pension_age_not_reached

#A3
outcome :outcome_age_limit_reached_birth

#A4
outcome :outcome_age_limit_reached_payment
