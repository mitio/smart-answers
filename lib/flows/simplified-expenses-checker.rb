status :published
satisfies_need "100119"

#Q1 - new or existing business
multiple_choice :claimed_expenses_for_current_business? do
  option :yes
  option :no

  save_input_as :new_or_existing_business

  calculate :is_new_business do
    new_or_existing_business == "no"
  end

  calculate :is_existing_business do
    !is_new_business
  end

  next_node :type_of_expense?
end

#Q2 - type of expense
checkbox_question :type_of_expense? do
  option :car_or_van
  option :motorcycle
  option :using_home_for_business
  option :live_on_business_premises

  calculate :list_of_expenses do
    responses.last == "none" ? [] : responses.last.split(",")
  end

  validate do |response|
    (response.split(',') & %w{live_on_business_premises using_home_for_business}).size != 2
  end

  next_node_if(:you_cant_use_result) { |response| response == "none" }
  next_node_if(:buying_new_vehicle?, response_is_one_of(%w{car_or_van motorcycle}))
  next_node_if(:hours_work_home?, response_is_one_of(%w{using_home_for_business}))
  next_node_if(:deduct_from_premises?, response_is_one_of(%w{live_on_business_premises}))
end

#Q3 - buying new vehicle?
multiple_choice :buying_new_vehicle? do
  option yes: :is_vehicle_green?
  option :no

  next_node_if(:is_vehicle_green?, responded_with('yes'))
  next_node_if(:capital_allowances?) { is_existing_business }
  next_node(:how_much_expect_to_claim?)
end

#Q4 - capital allowances claimed?
# if yes => go to Result 3 if in Q2 only [car_van] and/or [motorcylce] was selected
#
# if yes and other expenses apart from cars and/or motorbikes selected in Q2 store as capital_allowance_claimed and add text to result (see result 2) and go to questions for other expenses, ie don’t go to Q5 & Q9
#
# if no go to Q5
multiple_choice :capital_allowances? do
  option :yes
  option :no

  calculate :capital_allowance_claimed do
    responses.last == "yes" and (list_of_expenses & %w(using_home_for_business live_on_business_premises)).any?
  end

  on_condition(responded_with('yes')) do
    # Q11
    next_node_if(:hours_work_home?) { list_of_expenses.include?("using_home_for_business") }
    # Q13
    next_node_if(:deduct_from_premises?) { list_of_expenses.include?("live_on_business_premises") }
    next_node(:capital_allowance_result)
  end
  next_node(:how_much_expect_to_claim?)
end

#Q5 - claim vehicle expenses
money_question :how_much_expect_to_claim? do
  save_input_as :vehicle_costs

  next_node_if(:drive_business_miles_car_van?) { list_of_expenses.include?("car_or_van") }
  next_node(:drive_business_miles_motorcycle?)
end

#Q6 - is vehicle green?
multiple_choice :is_vehicle_green? do
  option :yes
  option :no

  calculate :vehicle_is_green do
    responses.last == "yes"
  end

  next_node :price_of_vehicle?
end

#Q7 - price of vehicle
money_question :price_of_vehicle? do
  # if green => take user input and store as [green_cost]
  # if dirty  => take 18% of user input and store as [dirty_cost]
  # if input > 250k store as [over_van_limit]
  save_input_as :vehicle_price

  calculate :green_vehicle_price do
    vehicle_is_green ? vehicle_price : nil
  end

  calculate :dirty_vehicle_price do
    vehicle_is_green ? nil : (vehicle_price * 0.18)
  end

  calculate :is_over_limit do
    vehicle_price > 250000.0
  end

  next_node :vehicle_business_use_time?
end

#Q8 - vehicle private use time
value_question :vehicle_business_use_time? do
  # deduct percentage amount from [green_cost] or [dirty_cost] and store as [green_write_off] or [dirty_write_off]
  calculate :business_use_percent do
    responses.last.to_f
  end
  calculate :green_vehicle_write_off do
    vehicle_is_green ? Money.new(green_vehicle_price * ( business_use_percent / 100)) : nil
  end

  calculate :dirty_vehicle_write_off do
    vehicle_is_green ? nil : Money.new(dirty_vehicle_price * ( business_use_percent / 100))
  end

  validate { |response| response.to_i <= 100 }

  next_node_if(:drive_business_miles_car_van?) { list_of_expenses.include?("car_or_van") }
  next_node(:drive_business_miles_motorcycle?)
end

#Q9 - miles to drive for business car_or_van
value_question :drive_business_miles_car_van? do
  # Calculation:
  # [user input 1-10,000] x 0.45
  # [user input > 10,001]  x 0.25
  calculate :simple_vehicle_costs do
    answer = responses.last.gsub(",", "").to_f
    if answer <= 10000
      Money.new(answer * 0.45)
    else
      answer_over_amount = (answer - 10000) * 0.25
      Money.new(4500.0 + answer_over_amount)
    end
  end
  next_node_if(:drive_business_miles_motorcycle?) { list_of_expenses.include?("motorcycle") }
  next_node_if(:hours_work_home?) { list_of_expenses.include?("using_home_for_business") }
  next_node_if(:deduct_from_premises?) { list_of_expenses.include?("live_on_business_premises") }
  next_node(:you_can_use_result)
end

#Q10 - miles to drive for business motorcycle
value_question :drive_business_miles_motorcycle? do
  calculate :simple_motorcycle_costs do
    Money.new(responses.last.gsub(",", "").to_f * 0.24)
  end

  next_node_if(:hours_work_home?) { list_of_expenses.include?("using_home_for_business") }
  next_node_if(:deduct_from_premises?) { list_of_expenses.include?("live_on_business_premises") }
  next_node(:you_can_use_result)
end

#Q11 - hours for home work
value_question :hours_work_home? do

  calculate :hours_worked_home do
    responses.last.gsub(",", "").to_f
  end

  calculate :simple_home_costs do
    amount = case hours_worked_home
             when 0..24 then 0
             when 25..50 then 120
             when 51..100 then 216
             else 312
             end
    Money.new(amount)
  end

  validate { |response| response.to_i >= 1 }
  next_node_if(:you_cant_use_result) { |response| response.to_i < 25 }
  next_node(:current_claim_amount_home?)
end

#Q12 - how much do you claim?
money_question :current_claim_amount_home? do
  save_input_as :home_costs

  next_node_if(:deduct_from_premises?) { list_of_expenses.include?("live_on_business_premises") }
  next_node(:you_can_use_result)
end

#Q13 = how much do you deduct from premises for private use?
money_question :deduct_from_premises? do
  save_input_as :business_premises_cost

  next_node :people_live_on_premises?
end

#Q14 - people who live on business premises?
value_question :people_live_on_premises? do
  calculate :live_on_premises do
    responses.last.to_i
  end

  calculate :simple_business_costs do
    amount = case live_on_premises
             when 0 then 0
             when 1 then 4200
             when 2 then 6000
             else 7800
             end

    Money.new(amount)
  end

  next_node :you_can_use_result
end

outcome :you_cant_use_result
outcome :you_can_use_result do
  precalculate :simple_heading do
    all_the_expenses = list_of_expenses
    live_on_premises = ['live_on_business_premises']

    if (all_the_expenses - live_on_premises).empty?
      PhraseList.new(:live_on_business_premises_only_simple_costs_heading)
    else
      PhraseList.new(:all_schemes_simple_costs_heading)
    end
  end

  precalculate :current_scheme_costs_heading do
    all_the_expenses = list_of_expenses
    live_on_premises = ['live_on_business_premises']

    if (all_the_expenses - live_on_premises).empty?
      PhraseList.new(:live_on_business_premises_only_current_costs_heading)
    else
      PhraseList.new(:all_schemes_current_costs_heading)
    end
  end

  precalculate :simple_total do
    vehicle = simple_vehicle_costs.to_f || 0
    motorcycle = simple_motorcycle_costs.to_f || 0
    home = simple_home_costs.to_f || 0

    Money.new(vehicle + motorcycle + home)
  end

  precalculate :current_scheme_costs do
    vehicle = vehicle_costs.to_f || 0
    green = green_vehicle_write_off.to_f || 0
    dirty = dirty_vehicle_write_off.to_f || 0
    home = home_costs.to_f || 0
    Money.new(vehicle + green + dirty + home)
  end

  precalculate :can_use_simple do
    simple_total > current_scheme_costs
  end

  precalculate :simplified_bullets do
    bullets = PhraseList.new
    bullets << :simple_vehicle_costs_bullet unless capital_allowance_claimed or simple_vehicle_costs.to_f == 0.0
    bullets << :simple_motorcycle_costs_bullet unless simple_motorcycle_costs.to_f == 0.0
    if list_of_expenses.include?("using_home_for_business")
      # if they ticked it but the cost is 0, it should show anyway
      if simple_home_costs.to_f == 0.0
        bullets << :simple_home_costs_none_bullet
      else
        bullets << :simple_home_costs_bullet
      end
    end
    bullets
  end

  precalculate :simplified_more_bullets do
    bullets = PhraseList.new
    bullets << :simple_business_costs_bullet unless simple_business_costs.to_f == 0.0
    bullets
  end

  precalculate :current_scheme_more_bullets do
    bullets = PhraseList.new
    bullets << :current_business_costs_bullet unless simple_business_costs.to_f == 0.0
    bullets
  end

  precalculate :capital_allowances_claimed_message do
    capital_allowance_claimed ? PhraseList.new(:cap_allow_text) : PhraseList.new
  end

  precalculate :current_scheme_bullets do
    bullets = PhraseList.new
    bullets << :current_vehicle_cost_bullet unless vehicle_costs.to_f == 0.0
    bullets << :current_green_vehicle_write_off_bullet unless green_vehicle_write_off.to_f == 0.0
    bullets << :current_dirty_vehicle_write_off_bullet unless dirty_vehicle_write_off.to_f == 0.0
    bullets << :current_home_costs_bullet unless home_costs.to_f == 0.0
    bullets
  end

  precalculate :over_van_limit_message do
    is_over_limit ? PhraseList.new(:over_van_limit) : PhraseList.new
  end
end
outcome :capital_allowance_result
