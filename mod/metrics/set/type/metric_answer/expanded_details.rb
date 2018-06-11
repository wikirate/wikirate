include_set Abstract::WikirateTable
include_set Abstract::ExpandedResearchedDetails
include_set Abstract::Table
include_set Abstract::Paging

# The following views handle the extra "expanded" details that are shown
# after clicking on an answer within a record.

# We can't distinguish with sets between metric answers of metrics
# of different metric types so we have different views for every metric type here.

format :html do
  view :expanded_details do
    render("expanded_#{card.metric_type}_details").html_safe
  end

  # Note: RESEARCHED details are handled in Abstract::ExpandedResearchedDetails

  # ~~~~~ FORMULA DETAILS

  # don't cache; view depends on formula card
  view :expanded_formula_details, tags: :unknown_ok, cache: :never do
    return render_expanded_researched_details if researched_value?
    expanded_formula_details
  end

  def expanded_formula_details
    wrap_expanded_details do
      wrap_with :div, [answer_details_table, calculation_details]
    end
  end

  # TODO: move to haml
  def calculation_details
    [
      wrap_with(:h5, "Formula"),
      wrap_with(:div, "= #{formula_details}", class: "formula-with-values")
    ]
  end

  # TODO: make item-wrapping format-specific
  def formula_details
    calculator = Formula::Calculator.new(card.metric_card.formula_card)
    calculator.formula_for card.company, card.year.to_i do |input|
      input = input.join ", " if input.is_a?(Array)
      "<span class='metric-value'>#{input}</span>"
    end
  end

  # ~~~~~ SCORE AND WIKIRATING DETAILS

  view :expanded_score_details, cache: :never do
    wrap_expanded_details do
      answer_details_table
    end
  end

  view :expanded_wiki_rating_details, cache: :never do
    wrap_expanded_details do
      wrap_with :div do
        [
          answer_details_table,
          wrap_with(:div, class: "col-md-12") do
            wrap_with(:div, class: "pull-right") { "= #{colorify card.value}" }
          end
        ]
      end
    end
  end

  def answer_details_table
    AnswerDetailsTable.new(self).render
  end

  # ~~~~~~~ RELATIONSHIP AND INVERSE RELATIONSHIP DETAILS

  view :expanded_relationship_details do
    wrap_expanded_details do
      [
        "<br/><h5>Relations</h5>",
        render_relations_table_with_details_toggle.html_safe
      ]
    end
  end

  view :expanded_inverse_relationship_details do
    render :expanded_relationship_details
  end

  view :relations_table_with_details_toggle, cache: :never do
    wrap do
      with_paging view: :relations_table_with_details_toggle do
        relations_table
      end
    end
  end

  def relations_table value_view=:details
    name_view = inverse? ? :inverse_company_name : :company_name
    wikirate_table :company, search_with_params, [name_view, value_view],
                   header: %w[Company Answer]
  end

  # ~~~~~~~~~ DESCENDANT DETAILS

  view :expanded_descendant_details do
    "(descendant answer details coming soon)"
  end
end
