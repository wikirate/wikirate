class Card
  # Query lookup table for relationships
  class RelationshipQuery < LookupQuery
    include AnswerQuery::AnswerFilters
    include AnswerQuery::ValueFilters
    include AnswerQuery::MetricFilters
    include AnswerQuery::CompanyFilters

    self.simple_filters = ::Set.new(
      %i[subject_company_id object_company_id
         metric_id inverse_metric_id
         answer_id inverse_answer_id]
    )

    def lookup_class
      ::Relationship
    end

    def lookup_table
      "relationships"
    end

    def normalize_filter_args
      # NOTE: without this filtering for published answers can break things.
      # Almost certainly need more sophisticated solution. (As is it probably will export
      # relationships associated with unpublished answers.)
      @filter_args.delete :published
    end

    def filter_by_subject_company_name value
      restrict_by_cql :subject_company_name, :subject_company_id,
                      name: [:match, value], type: :company
    end

    def filter_by_object_company_name value
      restrict_by_cql :object_company_name, :object_company_id,
                      name: [:match, value], type: :company
    end

    def filter_by_source value
      restrict_by_cql :source, :relationship_id,
                      right: :source, refer_to: value, return: :left_id
    end
  end
end

::Relationship.const_get("ActiveRecord_Relation")
              .send :include, Card::LookupQuery::ActiveRecordExtension
