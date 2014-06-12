status :published
satisfies_need "100306"

## Q1
multiple_choice :type_of_student? do
  option :"uk-full-time" => :form_needed_for_1?
  option :"uk-part-time" => :form_needed_for_2?
  option :"eu-full-time" => :what_year?
  option :"eu-part-time" => :what_year?

  save_input_as :student_type

  calculate :form_destination do
    if responses.last == 'uk-full-time' or responses.last == 'uk-part-time'
      PhraseList.new(:postal_address_uk)
    else
      PhraseList.new(:postal_address_eu)
    end
  end
end

## Q2a
multiple_choice :form_needed_for_1? do
  option :"apply-loans-grants"
  option :"proof-identity"
  option :"income-details"
  option :"apply-dsa"
  option :"dsa-expenses" => :outcome_dsa_expenses
  option :"apply-ccg"
  option :"ccg-expenses" => :outcome_ccg_expenses
  option :"travel-grant" => :outcome_travel

  save_input_as :form_required

  next_node(:what_year?)
end

## Q2b
multiple_choice :form_needed_for_2? do
  option :"apply-loans-grants"
  option :"proof-identity"
  option :"apply-dsa"
  option :"dsa-expenses" => :outcome_dsa_expenses

  save_input_as :form_required

  next_node(:what_year?)
end

## Q3
multiple_choice :what_year? do
  option :"year-1314"
  option :"year-1415"

  save_input_as :year_required

  on_condition(variable_matches(:student_type, %w{uk-full-time uk-part-time})) do
    on_condition(responded_with('year-1314')) do
      on_condition(variable_matches(:student_type, 'uk-part-time')) do
        next_node_if(:outcome_proof_identity_1314_pt, variable_matches(:form_required, 'proof-identity'))
        next_node_if(:outcome_dsa_1314_pt, variable_matches(:form_required, 'apply-dsa'))
      end
      next_node_if(:outcome_proof_identity_1314, variable_matches(:form_required, 'proof-identity'))
      next_node_if(:outcome_parent_partner_1314, variable_matches(:form_required, 'income-details'))
      next_node_if(:outcome_dsa_1314, variable_matches(:form_required, 'apply-dsa'))
      next_node_if(:outcome_ccg_1314, variable_matches(:form_required, 'apply-ccg'))
    end
    on_condition(variable_matches(:student_type, 'uk-part-time')) do
      next_node_if(:outcome_dsa_1415_pt, variable_matches(:form_required, 'apply-dsa'))
    end
    next_node_if(:outcome_proof_identity_1415, variable_matches(:form_required, 'proof-identity'))
    next_node_if(:outcome_parent_partner_1415, variable_matches(:form_required, 'income-details'))
    next_node_if(:outcome_dsa_1415, variable_matches(:form_required, 'apply-dsa'))
    next_node_if(:outcome_ccg_1415, variable_matches(:form_required, 'apply-ccg'))
  end
  next_node(:continuing_student?)
end

## Q4
multiple_choice :continuing_student? do
  option :"continuing-student"
  option :"new-student"

  save_input_as :continuing_student_state

  on_condition(variable_matches(:student_type, "uk-part-time")) do
    next_node_if(:pt_course_start?, variable_matches(:form_required, 'apply-loans-grants'))
  end

  on_condition(variable_matches(:year_required, "year-1314")) do
    on_condition(variable_matches(:student_type, "uk-full-time")) do
      on_condition(variable_matches(:form_required, "apply-loans-grants")) do
        next_node_if(:outcome_uk_ft_1314_continuing, responded_with('continuing-student'))
        next_node(:outcome_uk_ft_1314_new)
      end
    end
    on_condition(variable_matches(:student_type, "eu-full-time")) do
      next_node_if(:outcome_eu_ft_1314_continuing, responded_with('continuing-student'))
      next_node(:outcome_eu_ft_1314_new)
    end
    on_condition(variable_matches(:student_type, "eu-part-time")) do
      next_node_if(:outcome_eu_pt_1314_continuing, responded_with('continuing-student'))
      next_node(:outcome_eu_pt_1314_new)
    end
  end

  on_condition(variable_matches(:year_required, "year-1415")) do
    on_condition(variable_matches(:student_type, "uk-full-time")) do
      on_condition(variable_matches(:form_required, "apply-loans-grants")) do
        next_node_if(:outcome_uk_ft_1415_continuing, responded_with('continuing-student'))
        next_node(:outcome_uk_ft_1415_new)
      end
    end
    on_condition(variable_matches(:student_type, "eu-full-time")) do
      next_node_if(:outcome_eu_ft_1415_continuing, responded_with('continuing-student'))
      next_node(:outcome_eu_ft_1415_new)
    end
    on_condition(variable_matches(:student_type, "eu-part-time")) do
      next_node_if(:outcome_eu_pt_1415_continuing, responded_with('continuing-student'))
      next_node(:outcome_eu_pt_1415_new)
    end
  end
end

##Q5
multiple_choice :pt_course_start? do
  option :"course-start-before-01092012"
  option :"course-start-after-01092012"

  on_condition(variable_matches(:year_required, 'year-1314')) do
    next_node_if(:outcome_uk_pt_1314_grant, responded_with('course-start-before-01092012'))
    next_node_if(:outcome_uk_pt_1314_continuing, variable_matches(:continuing_student_state, 'continuing-student'))
    next_node_if(:outcome_uk_pt_1314_new, variable_matches(:continuing_student_state, 'new-student'))
  end

  on_condition(variable_matches(:year_required, 'year-1415')) do
    next_node_if(:outcome_uk_pt_1415_grant, responded_with('course-start-before-01092012'))
    next_node_if(:outcome_uk_pt_1415_continuing, variable_matches(:continuing_student_state, 'continuing-student'))
    next_node_if(:outcome_uk_pt_1415_new, variable_matches(:continuing_student_state, 'new-student'))
  end
end

outcome :outcome_uk_ft_1314_new
outcome :outcome_uk_ft_1314_continuing
outcome :outcome_uk_ft_1415_new
outcome :outcome_uk_ft_1415_continuing
outcome :outcome_uk_pt_1314_new
outcome :outcome_uk_pt_1314_continuing
outcome :outcome_uk_pt_1314_grant
outcome :outcome_uk_pt_1415_new
outcome :outcome_uk_pt_1415_continuing
outcome :outcome_uk_pt_1415_grant
outcome :outcome_parent_partner_1314
outcome :outcome_parent_partner_1415
outcome :outcome_proof_identity_1314
outcome :outcome_proof_identity_1314_pt
outcome :outcome_proof_identity_1415
outcome :outcome_dsa_1314
outcome :outcome_dsa_1314_pt
outcome :outcome_dsa_1415
outcome :outcome_dsa_1415_pt
outcome :outcome_ccg_1314
outcome :outcome_ccg_1415
outcome :outcome_dsa_expenses
outcome :outcome_ccg_expenses
outcome :outcome_travel
outcome :outcome_eu_ft_1314_new
outcome :outcome_eu_ft_1314_continuing
outcome :outcome_eu_pt_1314_new
outcome :outcome_eu_pt_1314_continuing
outcome :outcome_eu_ft_1415_new
outcome :outcome_eu_ft_1415_continuing
outcome :outcome_eu_pt_1415_new
outcome :outcome_eu_pt_1415_continuing
