status :published
satisfies_need "100233"

# Q1
multiple_choice :how_much_starch_glucose? do
  option 0 => :how_much_sucrose_1?
  option 5 => :how_much_sucrose_1?
  option 25 => :how_much_sucrose_2?
  option 50 => :how_much_sucrose_3?
  option 75 => :how_much_sucrose_4?

  save_input_as :starch_glucose_weight
end

# Q2ab
multiple_choice :how_much_sucrose_1? do
  option 0
  option 5
  option 30
  option 50
  option 70

  save_input_as :sucrose_weight
  next_node :how_much_milk_fat?
end

# Q2c
multiple_choice :how_much_sucrose_2? do
  option 0
  option 5
  option 30
  option 50

  save_input_as :sucrose_weight
  next_node :how_much_milk_fat?
end

# Q2d
multiple_choice :how_much_sucrose_3? do
  option 0
  option 5
  option 30

  save_input_as :sucrose_weight
  next_node :how_much_milk_fat?
end

# Q2e
multiple_choice :how_much_sucrose_4? do
  option 0
  option 5

  save_input_as :sucrose_weight
  next_node :how_much_milk_fat?
end

# Q3
multiple_choice :how_much_milk_fat? do
  option 0 => :how_much_milk_protein_ab?
  option 1 => :how_much_milk_protein_ab?
  option 3 => :how_much_milk_protein_c?
  option 6 => :how_much_milk_protein_d?
  option 9 => :how_much_milk_protein_ef?
  option 12 => :how_much_milk_protein_ef?
  option 18 => :how_much_milk_protein_gh?
  option 26 => :how_much_milk_protein_gh?
  option 40 => :commodity_code_result
  option 55 => :commodity_code_result
  option 70 => :commodity_code_result
  option 85 => :commodity_code_result

  calculate :calculator do
    Calculators::CommodityCodeCalculator.new(
      starch_glucose_weight: starch_glucose_weight,
      sucrose_weight: sucrose_weight,
      milk_fat_weight: responses.last,
      milk_protein_weight: 0)
  end

  calculate :commodity_code do
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end

  save_input_as :milk_fat_weight
end

# Q3ab
multiple_choice :how_much_milk_protein_ab? do
  option 0
  option 2
  option 6
  option 18
  option 30
  option 60

  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

# Q3c
multiple_choice :how_much_milk_protein_c? do
  option 0
  option 2
  option 12

  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

# Q3d
multiple_choice :how_much_milk_protein_d? do
  option 0
  option 4
  option 15

  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

# Q3ef
multiple_choice :how_much_milk_protein_ef? do
  option 0
  option 6
  option 18

  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

# Q3gh
multiple_choice :how_much_milk_protein_gh? do
  option 0
  option 6

  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

outcome :commodity_code_result do
  precalculate :additional_info do
    if commodity_code != 'X'
      PhraseList.new(:result_explanation_code)
    else
      ''
    end
  end
end
