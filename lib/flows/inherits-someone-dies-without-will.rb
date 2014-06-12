status :published
satisfies_need "100988"

# The case & if blocks in this file are organised to be read in the same order
# as the flow chart rather than to minimise repetition.

# Q1
multiple_choice :region? do
  option :"england-and-wales"
  option :"scotland"
  option :"northern-ireland"

  save_input_as :region

  calculate :next_step_links do
    PhraseList.new(:wills_link, :inheritance_link)
  end

  next_node :partner?
end

# Q2
multiple_choice :partner? do
  option :yes
  option :no

  save_input_as :partner

  on_condition(responded_with('yes')) do
    next_node_if(:estate_over_250000?) do
      ["england-and-wales", "northern-ireland"].include?(region)
    end
  end
  next_node(:children?)
end

# Q3
multiple_choice :estate_over_250000? do
  option :yes => children?
  option :no

  save_input_as :estate_over_250000

  calculate :next_step_links do
    if estate_over_250000 == "yes"
      next_step_links
    else
      PhraseList.new(:wills_link)
    end
  end

  next_node_if(:outcome_1) { region == "england-and-wales" }
  next_node_if(:outcome_60) { region == "northern-ireland" }
end

# Q4
multiple_choice :children? do
  option :yes
  option :no => parents?

  save_input_as :children

  on_condition(->(_) { partner == 'yes' } ) do
    next_node_if(:outcome_20) { region == 'england-and-wales'}
    next_node_if(:outcome_40) { region == 'scotland'}
    next_node_if(:more_than_one_child?) { region == 'northern-ireland'}
  end

  on_condition(->(_) { partner == 'no' } ) do
    next_node_if(:outcome_66) { region == 'northern-ireland'}
    next_node(:outcome_2)
  end
end

# Q5
multiple_choice :parents? do
  option :yes
  option :no

  save_input_as :parents

  next_node_if(:siblings?) { region == 'scotland' }

  on_condition(->(_) { partner == 'yes' } ) do
    on_condition(responded_with('yes')) do
      next_node_if(:siblings?) { region == 'england-and-wales'}
      next_node_if(:outcome_63) { region == 'northern-ireland'}
    end
    next_node_if(:outcome_1) { region == 'england-and-wales'}
    next_node_if(:siblings_including_mixed_parents?) { region == 'northern-ireland'}
  end
  next_node_if(:outcome_3, responded_with('yes'))
  next_node(:siblings?)
end

# Q6
multiple_choice :siblings? do
  option :yes
  option :no

  save_input_as :siblings

  next_node do |response|
    case region
    when "england-and-wales"
      if partner == "yes"
        response == "yes" ? :outcome_22 : :outcome_21
      else
        response == "yes" ? :outcome_4 : :half_siblings?
      end
    when "scotland"
      if partner == "yes"
        if parents == "yes"
          response == "yes" ? :outcome_43 : :outcome_42
        else
          response == "yes" ? :outcome_41 : :outcome_1
        end
      else
        if parents == "yes"
          response == "yes" ? :outcome_44 : :outcome_3
        else
          response == "yes" ? :outcome_4 : :aunts_or_uncles?
        end
      end
    when "northern-ireland"
      if partner == "yes"
        response == "yes" ? :outcome_64 : :outcome_65
      else
        response == "yes" ? :outcome_4 : :grandparents?
      end
    end
  end
  permitted_next_nodes(:outcome_22, :outcome_21, :outcome_22, :outcome_1, :outcome_43, :outcome_42, :outcome_41, :outcome_1, :outcome_44, :outcome_3, :outcome_4, :aunts_or_uncles?, :outcome_64, :outcome_65, :outcome_4, :grandparents?, :half_siblings?)
end

# Q61
multiple_choice :siblings_including_mixed_parents? do
  option :yes => outcome_64
  option :no => outcome_65

  save_input_as :siblings
end

# Q7
multiple_choice :grandparents? do
  option :yes => outcome_5
  option :no

  save_input_as :grandparents

  next_node_if(:great_aunts_or_uncles?) { region == 'scotland'}
  next_node(:aunts_or_uncles?)
end

# Q8
multiple_choice :aunts_or_uncles? do
  option :yes => outcome_6
  option :no

  save_input_as :aunts_or_uncles

  next_node_if(:half_aunts_or_uncles?) { region == 'england-and-wales'}
  next_node_if(:grandparents?) { region == 'scotland'}
  next_node_if(:outcome_67) { region == 'northern-ireland'}
end

# Q20
multiple_choice :half_siblings? do
  option :yes => outcome_23
  option :no => grandparents?

  save_input_as :half_siblings
end

# Q21
multiple_choice :half_aunts_or_uncles? do
  option :yes => outcome_24
  option :no => outcome_25

  save_input_as :half_aunts_or_uncles
end

# Q40
multiple_choice :great_aunts_or_uncles? do
  option :yes => outcome_45
  option :no => outcome_46

  save_input_as :great_aunts_or_uncles
end

# Q60
multiple_choice :more_than_one_child? do
  option :yes => outcome_61
  option :no => outcome_62

  save_input_as :more_than_one_child
end

outcome :outcome_1
outcome :outcome_2
outcome :outcome_3
outcome :outcome_4
outcome :outcome_5
outcome :outcome_6

outcome :outcome_20
outcome :outcome_21
outcome :outcome_22
outcome :outcome_23
outcome :outcome_24

outcome :outcome_25 do
  precalculate :next_step_links do
    PhraseList.new(:ownerless_link)
  end
end

outcome :outcome_40
outcome :outcome_41
outcome :outcome_42
outcome :outcome_43
outcome :outcome_44
outcome :outcome_45

outcome :outcome_46 do
  precalculate :next_step_links do
    PhraseList.new(:ownerless_link)
  end
end

outcome :outcome_60
outcome :outcome_61
outcome :outcome_62
outcome :outcome_63
outcome :outcome_64
outcome :outcome_65
outcome :outcome_66

outcome :outcome_67 do
  precalculate :next_step_links do
    PhraseList.new(:ownerless_link)
  end
end
