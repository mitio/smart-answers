status :draft
satisfies_need "100405"

situations = ['going_abroad', 'already_abroad']

eea_countries = %w(austria belgium bulgaria cyprus czech-republic denmark estonia finland france germany gibraltar greece hungary iceland ireland italy latvia liechtenstein lithuania luxembourg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)
former_yugoslavia = %w(croatia bosnia-and-herzegovina kosovo macedonia montenegro serbia)
social_security_countries = former_yugoslavia + %w(guernsey jersey new-zealand)
maternity_ss_countries = social_security_countries + %w(barbados israel jersey turkey)

# Predicates
p_eea_country = ->(response) { eea_countries.include?(response) }

# Q1
multiple_choice :going_or_already_abroad? do
  option :going_abroad
  option :already_abroad
  save_input_as :going_or_already_abroad
  next_node :which_benefit?
end
# Q2
multiple_choice :which_benefit? do
  option jsa: :which_country_jsa? # Q3
  option pension: :pension_outcome # A2
  option wfp: :which_country_wfp? # Q4
  option maternity_benefits: :which_country_maternity? # Q6
  option child_benefits: :which_country_cb? # Q11
  option iidb: :already_claiming_iidb? # Q22
  option ssp: :which_country_ssp? # Q31
  option esa: :how_long_are_you_abroad_for_esa? # Q23
  #option :disability_benefits => # Q26 # Leave for now.
  option bereavement_benefits: :which_country_bereavement? # Q32
  option tax_credits: :eligible_for_tax_credits? # Q16
end
# Q3
country_select :which_country_jsa? do
  situations.each do |situation|
    key = :"which_country_#{situation}_jsa"
    precalculate key do
      PhraseList.new key
    end
  end

  next_node_if(:jsa_eea_going_abroad) {|r| going_or_already_abroad == 'going_abroad' && eea_countries.include?(r) }
  next_node_if(:jsa_eea_already_abroad) {|r| going_or_already_abroad == 'already_abroad' && eea_countries.include?(r) }
  next_node_if(:jsa_social_security) {|r| social_security_countries.include?(r) }
  next_node(:jsa_not_entitled) # A5
end
# Q4
country_select :which_country_wfp? do
  situations.each do |situation|
    key = :"which_country_#{situation}_wfp"
    precalculate key do
      PhraseList.new key
    end
  end
  next_node_if(:qualify_for_wfp?, &p_eea_country) # Q5
  next_node(:wfp_not_entitled) # A6
end
# Q5
multiple_choice :qualify_for_wfp? do
  option yes: :wfp_outcome # A7
  option no: :wfp_not_entitled # A6
end
# Q6
country_select :which_country_maternity? do
  save_input_as :maternity_country
  situations.each do |situation|
    key = :"which_country_#{situation}_maternity"
    precalculate key do
      PhraseList.new key
    end
  end
  next_node_if(:working_for_a_uk_employer?, &p_eea_country) # Q7
  next_node(:employer_paying_ni?) # Q9, Q10
end
# Q7
multiple_choice :working_for_a_uk_employer? do
  option yes: :eligible_for_maternity_pay? # Q8
  option no: :smp_not_entitled # A8
   situations.each do |situation|
    key = :"uk_employer_#{situation}_maternity"
    precalculate key do
      PhraseList.new key
    end
  end
end
# Q8
multiple_choice :eligible_for_maternity_pay? do
  option yes: :smp_outcome # A9
  option no: :smp_not_entitled #A8
end
# Q9, Q10
multiple_choice :employer_paying_ni? do
  option :yes
  option :no
  next_node_if(:eligible_for_maternity_pay?) {|r| r == "yes"}  # Q8
  next_node_if(:maternity_allowance) { maternity_ss_countries.include?(maternity_country) } # A10
  next_node(:maternity_not_entitled) # A11
end
# Q11
country_select :which_country_cb? do
  situations.each do |situation|
    key = :"which_country_#{situation}_cb"
    precalculate key do
      PhraseList.new key
    end
  end
  next_node_if(:do_either_of_the_following_apply?, &p_eea_country) # Q12
  next_node_if(:cb_fy_social_security_outcome) { |r| former_yugoslavia.include?(r)} # A12
  next_node_if(:cb_social_security_outcome) { |r| %w(barbados canada guernsey israel jersey mauritius new-zealand).include?(r) } # A13
  next_node_if(:cb_jtu_not_entitled) { |r| %w(jamaica turkey united-states).include?(r) } # A14
  next_node(:cb_not_entitled) # A16
end
# Q12
multiple_choice :do_either_of_the_following_apply? do
  option yes: :cb_outcome # A15
  option no: :cb_not_entitled # A16
end
# Q13
country_select :which_country_ssp? do
  situations.each do |situation|
    key = :"which_country_#{situation}_ssp"
    precalculate key do
      PhraseList.new key
    end
  end
  next_node_if(:working_for_a_uk_employer_ssp?, &p_eea_country) # Q14
  next_node(:employer_paying_ni_ssp?) # Q15
end
# Q14
multiple_choice :working_for_a_uk_employer_ssp? do
  option yes: :ssp_outcome # A17
  option no: :ssp_not_entitled # A18
end
# Q15
multiple_choice :employer_paying_ni_ssp? do
  option yes: :ssp_outcome # A17
  option no: :ssp_not_entitled # A18
end
# Q16
multiple_choice :eligible_for_tax_credits? do
  option yes: :are_you_one_of_the_following? # Q17
  option no: :tax_credits_unlikely # A19
  situations.each do |situation|
    key = :"eligible_#{situation}_tax_credits"
    precalculate key do
      PhraseList.new key
    end
  end
end
# Q17
multiple_choice :are_you_one_of_the_following? do
  option crown_servant: :tax_credits_outcome # A20
  option cross_border_worker: :tax_credits_exceptions # A21
  option none_of_the_above: :how_long_are_you_abroad_for? # Q21
end
# Q18
multiple_choice :do_you_have_children? do
  option yes: :where_tax_credits? # Q19
  option no: :tax_credits_outcome # A20
end
# Q19
country_select :where_tax_credits? do
  situations.each do |situation|
    key = :"where_#{situation}_tax_credits"
    precalculate key do
      PhraseList.new key
    end
  end
  next_node_if(:currently_claiming?, &p_eea_country) # Q20
  next_node(:tax_credits_unlikely) # A19
end
# Q20
multiple_choice :currently_claiming? do
  option yes: :tax_credits_possible # A22
  option no: :tax_credits_unlikely # A19
end
# Q21
multiple_choice :how_long_are_you_abroad_for? do
  option up_to_a_year: :why_are_you_going_abroad? # Q22
  option more_than_a_year: :do_you_have_children? # Q18
  situations.each do |situation|
    key = :"how_long_#{situation}_tax_credits"
    precalculate key do
      PhraseList.new key
    end
  end
end
# Q22
multiple_choice :why_are_you_going_abroad? do
  option holiday_or_business_trip: :tax_credits_continue_8_weeks # A23
  option medical_treatment: :tax_credits_continue_12_weeks # A24
  option death: :tax_credits_continue_12_weeks # A24
end
# Q23
multiple_choice :how_long_are_you_abroad_for_esa? do
  option less_than_a_year_medical: :esa_eligible_26_weeks # A25
  option less_than_a_year: :esa_eligible_4_weeks # A26
  option more_than_a_year: :which_country_esa? # Q24
end
# Q24
country_select :which_country_esa?, use_legacy_data: true do
  next_node_if(:esa_eligible_possible, &p_eea_country) # A27
  next_node(:esa_not_entitled) # A28
end
# Q25
multiple_choice :already_claiming_iidb? do
  option yes: :which_country_iidb? # Q26
  option no: :iidb_possible_with_ni # A29
end
# Q26

country_select :which_country_iidb?, use_legacy_data: true do
  iidb_ss_countries = %w(barbados bermuda bosnia-and-herzegovina croatia guernsey israel
                         jamaica jersey kosovo macedonia malta mauritius montenegro
                         philippines serbia)
  next_node_if(:iidb_outcome, &p_eea_country) # A30
  next_node_if(:iidb_ss_possible) { |r| iidb_ss_countries.include?(r) } # A31
  next_node(:iidb_not_entitled) # A32
end

# Q32
country_select :which_country_bereavement? do
  bereavement_ss_countries = %w(barbados bermuda bosnia-and-herzegovina canada croatia
                                guernsey israel jamaica jersey kosovo macedonia malta
                                mauritius montenegro philippines serbia turkey united-states)
  next_node_if(:bereavement_outcome, &p_eea_country) # A36
  next_node_if(:bereavement_benefit_possible) { |r| bereavement_ss_countries.include?(r) } # A37
  next_node(:bereavement_not_entitled) # A38
end

# A1
outcome :not_paid_ni
# A2
outcome :pension_outcome
# A3
outcome :jsa_eea_going_abroad
outcome :jsa_eea_already_abroad
# A4
outcome :jsa_social_security
# A5
outcome :jsa_not_entitled
# A6
outcome :wfp_not_entitled
# A7
outcome :wfp_outcome
# A8
outcome :smp_not_entitled
# A9
outcome :smp_outcome
# A10
outcome :maternity_allowance
# A11
outcome :maternity_not_entitled
# A12
outcome :cb_fy_social_security_outcome
# A13
outcome :cb_social_security_outcome
# A14
outcome :cb_jtu_not_entitled
# A15
outcome :cb_outcome
# A16
outcome :cb_not_entitled
# A17
outcome :ssp_outcome
# A18
outcome :ssp_not_entitled
# A19
outcome :tax_credits_unlikely
# A20
outcome :tax_credits_outcome
# A21
outcome :tax_credits_exceptions
# A22
outcome :tax_credits_possible
# A23
outcome :tax_credits_continue_8_weeks
# A24
outcome :tax_credits_continue_12_weeks
# A25
outcome :esa_eligible_26_weeks
# A26
outcome :esa_eligible_4_weeks
# A27
outcome :esa_eligible_possible
# A28
outcome :esa_not_entitled
# A29
outcome :iidb_possible_with_ni
# A30
outcome :iidb_outcome
# A31
outcome :iidb_ss_possible
# A32
outcome :iidb_not_entitled
# A36
outcome :bereavement_outcome
# A37
outcome :bereavement_benefit_possible
# A38
outcome :bereavement_not_entitled
