include_set Abstract::ExpandedResearchedDetails
include_set Abstract::Table
include_set Abstract::Paging

# The following views handle the extra "expanded" details that are shown
# after clicking on an answer within a record.

# We can't distinguish with sets between metric answers of metrics
# of different metric types so we have different views for every metric type here.

format :html do
  view :expanded_details do
    wrap_with :div, class: "details-content" do
      render :"expanded_#{details_type}_details"
    end
  end

  def expanded_data_details_view
    if voo.root.ok_view == :metric_details_sidebar
      :metric_details_sidebar
    else
      :details_sidebar
    end
  end

  def details_type
    card.calculated? && researched_value? ? :researched : card.metric_type
  end

  def wrap_expanded_details
    output [yield, render_comments]
  end

  # Note: RESEARCHED details are handled in Abstract::ExpandedResearchedDetails

  # ~~~~~ FORMULA DETAILS

  # don't cache; view depends on formula card
  view :expanded_formula_details, unknown: true, cache: :never do
    expanded_formula_details
  end

  def expanded_formula_details
    wrap_expanded_details do
      wrap_with :div, [answer_details_table, calculation_details]
    end
  end

  def calculation_details
    formula_wrapper { formula_details }
  end

  # TODO: move to haml
  def formula_wrapper
    [wrap_with(:h5, "Formula"),
     wrap_with(:div, "= #{yield}", class: "formula-with-values")]
  end

  # TODO: make item-wrapping format-specific
  def formula_details
    parser = card.metric_card.formula_card.parser.processed_input!
    calculator = Formula::Calculator.new(parser)
    calculator.advanced_formula_for card.company,
                                    card.year.to_i do |input, input_card, index|
      input_value_link input, input_card, parser.year_options[index]
    end
  end

  def input_value_link input, input_card, year_option
    target = [input_card, card.company, input_value_link_year(input, year_option)]
    input = input.join ", " if input.is_a?(Array)
    link_to_card target.compact, input, class: "metric-value _update-details"
  end

  def input_value_link_year input, year_option
    input.is_a?(Array) && year_option ? nil : card.year
  end

  # ~~~~~ SCORE AND WIKIRATING DETAILS

  view :expanded_score_details, cache: :never do
    wrap_expanded_details do
      if metric_card.categorical?
        category_score_table_and_formula
      else
        [answer_details_table("FormulaScore"), calculation_details]
      end
    end
  end

  view :expanded_wiki_rating_details, cache: :never do
    wrap_expanded_details do
      wrap_with :div do
        [
          answer_details_table,
          wrap_with(:div, class: "col-md-12") do
            wrap_with(:div, class: "float-right") do
              "= #{nest card.value_card, view: :pretty}"
            end
          end
        ]
      end
    end
  end

  def category_score_table_and_formula
    details_object = AnswerDetailsTable.new self, "CategoryScore"
    [details_object.render, score_formula(details_object.table)]
  end

  def score_formula table
    return unless table.checked_options.size > 1
    formula_wrapper { table.score_links.join " + " }
  end

  def answer_details_table class_base=nil
    AnswerDetailsTable.new(self, class_base).render
  end

  # ~~~~~~~ RELATIONSHIP AND INVERSE RELATIONSHIP DETAILS

  view :expanded_relationship_details do
    wrap_researched_details do
      field_nest :relationship_search, view: :filtered_content
    end
  end

  view :expanded_inverse_relationship_details do
    render :expanded_relationship_details
  end

  # ~~~~~~~~~ DESCENDANT DETAILS

  view :expanded_descendant_details do
    wrap_expanded_details { answer_details_table }
  end
end
