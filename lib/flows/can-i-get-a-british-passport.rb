status :draft
satisfies_need "100983"

multiple_choice :do_you_have? do
  option british_citizenship: :is_one_of_these_true?
  option british_nationality: :describe_your_british_nationality?
  option british_partner: :british_partner_info
  option british_parent: :british_parent_info
end

multiple_choice :is_one_of_these_true? do
  save_input_as :eligibility

  option :born_in_uk
  option :born_in_british_colony
  option :naturalised
  option :uk_citizen_or_citizen_of_british_colony
  option :father_is_eligible
  option none_of_the_above: :do_not_qualify

  next_node(:date_of_birth?)
end

multiple_choice :describe_your_british_nationality? do
  option british_overseas_territories_citizen: :british_overseas_territories_citizen_info
  option british_overseas_citizen: :british_overseas_citizen_info
  option british_subject: :british_subject_info
  option british_protected_person: :british_protected_person_info
end

date_question :date_of_birth? do
  to { Date.parse('1 Jan 1896') }
  from { Date.today }

  next_node_calculation(:dob) { |r| Date.parse(r) }
  next_node_if(:you_qualify) { dob <= Date.parse('1983-01-01') }
  next_node_if(:parents_married_at_birth?) { dob > Date.parse('1983-01-01') and dob < Date.parse('2006-07-01') }
  next_node(:parent_eligibility_at_birth?)
end

multiple_choice :parents_married_at_birth? do
  option yes: :parent_eligibility_at_birth?
  option no: :mother_eligibility_at_birth?
end

multiple_choice :parent_eligibility_at_birth? do
  option yes: :you_qualify
  option no: :do_not_qualify
end

multiple_choice :mother_eligibility_at_birth? do
  option yes: :you_qualify
  option no: :do_not_qualify
end

outcome :you_qualify
outcome :do_not_qualify
outcome :british_overseas_territories_citizen_info
outcome :british_overseas_citizen_info
outcome :british_subject_info
outcome :british_protected_person_info
outcome :british_partner_info
outcome :british_parent_info
