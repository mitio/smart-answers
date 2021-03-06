module SmartdownAdapter
  class PreviousQuestionPagePresenter
    def initialize(smartdown_previous_question_page)
      @smartdown_previous_question_page = smartdown_previous_question_page
    end

    def questions
      @smartdown_previous_question_page.questions.map do |smartdown_previous_question|
        PreviousQuestionPresenter.new(smartdown_previous_question)
      end
    end
  end
end
