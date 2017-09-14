class Card
  class MetricFilterQuery < Card::FilterQuery
    def wikirate_topic_wql topic
      add_to_wql :right_plus, [WikirateTopicID, { refer_to: topic }]
    end

    alias topic_wql wikirate_topic_wql

    def wikirate_company_wql company
      add_to_wql :right_plus, company
    end

    alias company_wql wikirate_company_wql

    def project_wql project
      add_to_wql :referred_to_by, left: project, right_id: MetricID
    end

    def year_wql year
      return if year == "latest"
      add_to_wql :right_plus, type_id: WikirateCompanyID, right_plus: year
    end

    def designer_wql designer
      add_to_wql :part, designer
    end

    def metric_type_wql metric_type
      add_to_wql :right_plus, [MetricTypeID, { refer_to: metric_type }]
    end

    def research_policy_wql research_policy
      add_to_wql :right_plus, [ResearchPolicyID, { refer_to: research_policy }]
    end

    def importance_wql value
      values = Array(value).map &:to_sym
      return {} if values.size == 3 || values.empty?
      return {} unless Auth.signed_in? # FIXME: use session votes

      wql = { type_id: MetricID, limit: 0, return: :id }
      wql.merge vote_wql(values)
    end

    # @param values [Array<Symbol>] has to contains one or two of the symbols
    #   :upvotes, :downvotes, :novotes
    # @return wql to find cards that the signed in user has (not) voted on
    # TODO: move this to voting mod
    def vote_wql values
      if values.include? :novotes
        not_directions = missing_directions(values)
        { not: linked_to_by_vote_wql(not_directions) }
      else
        linked_to_by_vote_wql values
      end
    end

    def linked_to_by_vote_wql array
      vote_pointers = array.map { |v| vote_pointer_name(v) }
      { linked_to_by: [:in] + vote_pointers }
    end

    def vote_pointer_name direction
      "#{Auth.current.name}+#{Card.fetch_name direction}"
    end

    def missing_directions directions
      [:upvotes, :downvotes, :novotes] - directions
    end
  end
end
