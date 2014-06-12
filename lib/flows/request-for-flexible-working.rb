# -*- coding: utf-8 -*-
status :draft
satisfies_need "100992"

## Q1
multiple_choice :are_you_an_employee_or_employer? do
  option employee: :employee_which_ones_of_these_describes_you?
  option employer: :employer_which_ones_of_these_describes_your_employee?
end

## Q2
checkbox_question :employee_which_ones_of_these_describes_you? do
  option :under_17
  option :care_for_adult
  option :less_than_26_weeks
  option :agency_worker
  option :member_of_armed_forces
  option :request_in_last_12_months
  option :none_of_these

  next_node_if(:employee_no_right_to_apply, response_is_one_of(['none_of_these']))
  next_node_if(:employee_responsible_for_childs_upbringing?, response_is_only('under_17'))
  next_node_if(:employee_do_any_of_these_describe_the_adult_youre_caring_for?, response_is_only('care_for_adult'))

  next_node_if(:employee_no_right_to_apply, response_has_all_of(%w{under_17 care_for_adult}))

  next_node_if(:employee_no_right_to_apply,
    response_is_one_of(%w{less_than_26_weeks agency_worker member_of_armed_forces request_in_last_12_months})
  )
end

checkbox_question :employer_which_ones_of_these_describes_your_employee? do
  option :under_18
  option :care_for_adult
  option :less_than_26_weeks
  option :agency_worker
  option :member_of_armed_forces
  option :request_in_last_12_months

  next_node_if(:employer_responsible_for_childs_upbringing?, response_is_only("under_18"))
  next_node_if(:employer_do_any_of_these_describe_the_adult_being_cared_for?, response_is_only("care_for_adult"))
  next_node_if(:employer_no_right_to_apply, response_has_all_of(%w{under_18 care_for_adult}))
  next_node_if(:employer_no_right_to_apply, response_is_one_of(%w{less_than_26_weeks agency_worker member_of_armed_forces request_in_last_12_months}))
end

## Q3
multiple_choice :employee_responsible_for_childs_upbringing? do
  option yes: :employee_right_to_apply
  option no: :employee_no_right_to_apply
end

multiple_choice :employer_responsible_for_childs_upbringing? do
  option yes: :employer_right_to_apply
  option no: :employer_no_right_to_apply
end

## Q4
multiple_choice :employee_do_any_of_these_describe_the_adult_youre_caring_for? do
  option yes: :employee_right_to_apply
  option no: :employee_no_right_to_apply
end

multiple_choice :employer_do_any_of_these_describe_the_adult_being_cared_for? do
  option yes: :employer_right_to_apply
  option no: :employer_no_right_to_apply
end

## A1
outcome :employee_no_right_to_apply
outcome :employer_no_right_to_apply

## A2
outcome :employee_right_to_apply
outcome :employer_right_to_apply
