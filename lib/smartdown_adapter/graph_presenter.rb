module SmartdownAdapter
  class GraphPresenter
    def initialize(name)
      @name = name
      @flow = SmartdownAdapter::Registry.build_flow(name)
    end

    def labels
      Hash[@flow.nodes.map { |node| [node.name, graph_label_text(node)]}]
    end

    def adjacency_list
      @adjacency_list ||= begin
        adjacency_list = {}
        @flow.question_pages.each do |node|
          adjacency_list[node.name.to_s] = []
          node.next_nodes.each do |nextnode|
            nextnode.rules.each do |rule|
              adjacency_list = add_rule_to_adjacency_list(adjacency_list, node, rule)
            end
          end
        end
        @flow.outcomes.each do |node|
          adjacency_list[node.name.to_s] = []
        end
        adjacency_list
      end
    end

    def visualisable?
      @flow.question_pages.all? do |node|
        node.permitted_next_nodes.any?
      end
    end

    def to_hash
      {
        labels: labels,
        adjacencyList: adjacency_list
      }
    end

    private

    def add_rule_to_adjacency_list(adjacency_list, node, rule, parent_rules = [])
      if rule.is_a? Smartdown::Model::NestedRule
        rule.children.each do |rule_child|
          new_parent_rules = parent_rules + [rule]
          adjacency_list = add_rule_to_adjacency_list(adjacency_list, node, rule_child, new_parent_rules)
        end
      else
        adjacency_list[node.name.to_s] << [rule.outcome.to_s, rule_label(rule, parent_rules)]
      end
      adjacency_list
    end

    def rule_label(rule, parent_rules)
      all_rules = parent_rules.push(rule)
      predicate_labels = all_rules.map(&:predicate).map{ |predicate| predicate_label(predicate) }
      predicate_labels.join(" AND ")
    end

    def predicate_label(predicate)
      case predicate
        when Smartdown::Model::Predicate::Equality
          "#{predicate.varname} is #{predicate.expected_value}"
        when Smartdown::Model::Predicate::Named
          "#{predicate.name}"
        when Smartdown::Model::Predicate::SetMembership
          "#{predicate.varname} in [#{predicate.values.join(",")}]"
        else
          "Unknown predicate type #{predicate}"
      end
    end

    def graph_label_text(node)
      text = node.class.to_s.split("::").last + "\n-\n"
      case node
        when Smartdown::Api::QuestionPage
          if node.questions.count > 1
            text << word_wrap(node.title.to_s)
            text << "\n\n"
          end
          text << word_wrap(node.title.to_s)
          text << "\n\n"
          node.questions.each do |question|
            text << word_wrap(question.title.to_s)
            text << "\n\n"
            text << question.options.map do |option|
              "( ) #{option.value}: #{option.label}"
            end.join("\n")
            text << "\n\n"
          end
        when Smartdown::Api::Outcome
          candidate_texts = [
              node.title.to_s,
              node.name.to_s
          ]
          text << word_wrap(candidate_texts.find(&:present?))
        else
          text << "Unknown node type"
      end
      text
    end

    def word_wrap(text, line_width = 40)
      text.split("\n").collect! do |line|
        line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
      end * "\n"
    end

  end
end
