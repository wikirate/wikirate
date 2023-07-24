module GraphQL
  module Types
    # Root Query for GraphQL
    class Query < BaseObject
      include DeckorateSearch

      class << self
        include DeckorateFields
      end

      card_field :research_group, ResearchGroup
      cardtype_field :research_group, ResearchGroup
      card_field :company_group, CompanyGroup
      cardtype_field :company_group, CompanyGroup
      card_field :company, Company, :wikirate_company
      cardtype_field :company, Company, :wikirate_company
      card_field :metric, Metric, :metric
      lookup_field :metric, Metric, :metric
      card_field :answer, Answer, :metric_answer
      lookup_field :answer, Answer, :metric_answer
      card_field :relationship, Relationship, :relationship_answer
      cardtype_field :relationship, Relationship, :relationship_answer
      card_field :topic, Topic, :wikirate_topic
      cardtype_field :topic, Topic, :wikirate_topic
      card_field :dataset, Dataset
      cardtype_field :dataset, Dataset
      card_field :source, Source
      cardtype_field :source, Source

      def relationships limit: 10, offset: 0, **filter
        ::Relationship.limit(limit).offset(offset).all
      end
    end
  end
end
