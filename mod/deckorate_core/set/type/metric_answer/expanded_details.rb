include_set Abstract::ExpandedResearchedDetails
include_set Abstract::Table
include_set Abstract::Paging

# The following views handle the extra "expanded" details that are shown
# after clicking on an answer within a record.

# We can't distinguish with sets between metric answers of metrics
# of different metric types so we have different views for every metric type here.

format :html do
  view :expanded_details do
    with_overrides do
      wrap_with :div, class: "details-content" do
        render :"expanded_#{card.metric_type}_details"
      end
    end
  end

  view :core, :expanded_details

  # ~~~~~ FORMULA DETAILS

  # don't cache; view depends on formula card
  view :expanded_formula_details, unknown: true, cache: :never do
    wrap_with :div, [answer_details_table, calculation_details]
  end

  # ~~~~~~~ RELATIONSHIP AND INVERSE RELATIONSHIP DETAILS

  view :expanded_relationship_details do
    field_nest :relationship_answer, view: :filtered_content
  end

  view :expanded_inverse_relationship_details do
    render :expanded_relationship_details
  end

  # ~~~~~~~~~ DESCENDANT DETAILS

  view :expanded_descendant_details do
    answer_details_table
  end

  view :expanded_score_details, cache: :never do
    if metric_card.categorical?
      category_score_table_and_formula
    else
      [answer_details_table("FormulaScore"), calculation_details]
    end
  end

  view :expanded_wiki_rating_details, cache: :never do
    wrap_with :div do
      [
        answer_details_table,
        wrap_with(:div, class: "col-md-12") do
          wrap_with(:div, class: "float-end") do
            "= #{nest card.value_card, view: :pretty}"
          end
        end
      ]
    end
  end

  def answer_details_table class_base=nil
    AnswerDetailsTable.new(self, class_base).render
  end

  def calculation_details
    formula_wrapper { formula_details }
  end

  # TODO: move to haml
  def formula_wrapper
    [wrap_with(:h5, "Formula"),
     wrap_with(:div, "= #{yield}", class: "formula-content")]
  end

  def formula_calculator
    card.metric_card.calculator :processed
  end

  def formula_details
    card.metric_card.formula
  end

  def input_value_link value, input_card, year_option
    answer = [input_card, card.company, input_value_link_year(value, year_option)].compact
    modal_link Array.wrap(value).join(", "),
               path: { mark: answer },
               class: "metric-value"
  end

  def input_value_link_year value, year_option
    value.is_a?(Array) && year_option ? nil : card.year
  end

  def category_score_table_and_formula
    details_object = AnswerDetailsTable.new self, "CategoryScore"
    [details_object.render, score_formula(details_object.table)]
  end

  def score_formula table
    return unless table.checked_options.size > 1
    formula_wrapper { table.score_links.join " + " }
  end

  def with_overrides
    output [(overridden_answer if calculation_overridden?), yield].compact
  end

  def overridden_answer
    value = card.answer.overridden_value
    value = humanized_number value if card.metric_type.to_sym == :formula
    wrap_with(:div, class: "overridden-answer metric-value") { value }
  end
end
