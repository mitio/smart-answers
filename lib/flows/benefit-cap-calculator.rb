status :published
satisfies_need "100696"

# Q1
multiple_choice :receive_housing_benefit? do
  option yes: :working_tax_credit?
  option no: :outcome_not_affected_no_housing_benefit

  save_input_as :housing_benefit
end

# Q2
multiple_choice :working_tax_credit? do
  option :yes
  option :no

  next_node do |response|
    if response == 'yes'
      :outcome_not_affected_exemptions
    else
      :receiving_exemption_benefits?
    end
  end
end

#Q3
multiple_choice :receiving_exemption_benefits? do
  option yes: :outcome_not_affected_exemptions
  option no: :receiving_non_exemption_benefits?
end

#Q4
checkbox_question :receiving_non_exemption_benefits? do
  option :bereavement
  option :carers
  option :child_benefit
  option :child_tax
  option :esa
  option :guardian
  option :incapacity
  option :income_support
  option :jsa
  option :maternity
  option :sda
  option :widowed_mother
  option :widowed_parent
  option :widow_pension
  option :widows_aged

  next_node_calculation :benefit_related_questions do |response|
    questions = response.split(",").map { |r| :"#{r}_amount?" }
    questions << :housing_benefit_amount? if housing_benefit == 'yes'
    questions << :single_couple_lone_parent?
    questions
  end

  calculate :total_benefits do
    0
  end

  calculate :benefit_cap do
    0
  end

  next_node_if(:outcome_not_affected, responded_with('none'))
  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :bereavement_amount?, :carers_amount?, :child_benefit_amount?, :child_tax_amount?, :esa_amount?,
    :guardian_amount?, :incapacity_amount?, :income_support_amount?, :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?
  )
end

#Q5a
money_question :bereavement_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :carers_amount?, :child_benefit_amount?, :child_tax_amount?, :esa_amount?,
    :guardian_amount?, :incapacity_amount?, :income_support_amount?, :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5b
money_question :carers_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :child_benefit_amount?, :child_tax_amount?, :esa_amount?,
    :guardian_amount?, :incapacity_amount?, :income_support_amount?, :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )

end

#Q5c
money_question :child_benefit_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :child_tax_amount?, :esa_amount?,
    :guardian_amount?, :incapacity_amount?, :income_support_amount?, :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5d
money_question :child_tax_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :esa_amount?,
    :guardian_amount?, :incapacity_amount?, :income_support_amount?, :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )

end

#Q5e
money_question :esa_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :guardian_amount?, :incapacity_amount?, :income_support_amount?, :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5f
money_question :guardian_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :incapacity_amount?, :income_support_amount?, :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5g
money_question :incapacity_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :income_support_amount?, :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5h
money_question :income_support_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :jsa_amount?, :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5i
money_question :jsa_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :maternity_amount?,
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5j
money_question :maternity_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :sda_amount?, :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5k
money_question :sda_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :widowed_mother_amount?, :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5l
money_question :widowed_mother_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :widowed_parent_amount?, :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5m
money_question :widowed_parent_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :widow_pension_amount?,
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5n
money_question :widow_pension_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :widows_aged_amount?, :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5o
money_question :widows_aged_amount? do

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :housing_benefit_amount?, :single_couple_lone_parent?
  )
end

#Q5p
money_question :housing_benefit_amount? do

  save_input_as :housing_benefit_amount

  calculate :total_benefits do
    total_benefits + responses.last.to_f
  end

  next_node do
    benefit_related_questions.shift
  end

  permitted_next_nodes(
    :single_couple_lone_parent?
  )
end

#Q6
multiple_choice :single_couple_lone_parent? do
  option :single
  option :couple
  option :parent

  next_node_calculation(:benefit_cap) { |response| response == 'single' ? 350 : 500 }
  next_node_if(:outcome_affected_greater_than_cap) { total_benefits > benefit_cap }
  next_node(:outcome_not_affected_less_than_cap)
end

##OUTCOMES

## Outcome 1
outcome :outcome_not_affected_exemptions do
  precalculate :outcome_phrase do
    PhraseList.new(:outcome_not_affected_exemptions_phrase, :contact_details)
  end
end

## Outcome 2
outcome :outcome_not_affected_no_housing_benefit do
  precalculate :outcome_phrase do
    PhraseList.new(:outcome_not_affected_no_housing_benefit_phrase, :contact_details)
  end
end

## Outcome 3
outcome :outcome_affected_greater_than_cap do

  precalculate :total_benefits do
    sprintf("%.2f", total_benefits)
  end

  precalculate :housing_benefit_amount do
    sprintf("%.2f", housing_benefit_amount)
  end

  precalculate :total_over_cap do
    sprintf("%.2f", (total_benefits.to_f - benefit_cap.to_f))
  end

  precalculate :new_housing_benefit do
    amount = sprintf("%.2f", (housing_benefit_amount.to_f - total_over_cap.to_f))
    if amount < "0.5"
      amount = sprintf("%.2f", 0.5)
    end
    amount
  end

  precalculate :outcome_phrase do
    new_housing_benefit_amount = housing_benefit_amount.to_f - total_over_cap.to_f
    if new_housing_benefit_amount < 0.5
      PhraseList.new(:outcome_affected_greater_than_cap_phrase, :housing_benefit_not_zero, :estimate_only, :contact_details)
    else
      PhraseList.new(:outcome_affected_greater_than_cap_phrase, :estimate_only, :contact_details)
    end
  end
end

## Outcome 4
outcome :outcome_not_affected_less_than_cap do
  precalculate :outcome_phrase do
    PhraseList.new(:outcome_not_affected_less_than_cap_phrase, :contact_details)
  end

  precalculate :total_benefits do
    sprintf("%.2f", total_benefits)
  end

end

## Outcome 5
outcome :outcome_not_affected do
  precalculate :outcome_phrase do
    PhraseList.new(:outcome_not_affected_phrase, :contact_details)
  end
end
