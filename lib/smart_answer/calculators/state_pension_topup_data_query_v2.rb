module SmartAnswer::Calculators
  class StatePensionTopupDataQueryV2

    attr_reader :data

    def initialize
      @data = self.class.age_and_rates_data
    end

    def age_and_rates(age)
      data['age_and_rates'][age]
    end

    def self.age_and_rates_data
      @age_and_rates_data ||= YAML.load_file(Rails.root.join("lib", "data", "pension_top_up_data_v2.yml"))
    end
  end
end
