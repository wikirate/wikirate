include_set Abstract::Table
include_set Abstract::Paging

# The following views handle the extra "expanded" details that are shown
# after clicking on an answer within a record.

# We can't distinguish with sets between metric answers of metrics
# of different metric types so we have different views for every metric type here.

def map_input_answer_and_detail
  input_answers = direct_dependee_answers
  metric_card.input_metrics_and_detail.map.with_index do |(metric, detail), index|
    yield input_answers[index], metric, detail
  end
end

format :html do
  delegate :metric_card, to: :card

  view :expanded_details do
    if metric_card.researched?
      ""
    elsif card.overridden?
      overridden_answer_with_formula
    else
      render_calculation_details
    end
  end

  def answer_accordion_item metric, detail
    title = metric.card.format.metric_accordion_item_title detail: detail,
                                                           answer: render_bar_right
    if card.researched?
      wrap_with(:div, class: "list-group-item") { title }
    else
      accordion_item title, body: render_calculation_details
    end
  end

  view :calculation_details do
    class_up "accordion", "answer-accordion"
    calculation_only do
      [metric_card.format.preface, render_answer_accordion]
    end
  end

  view :answer_accordion do
    calculation_only do
      accordion do
        card.map_input_answer_and_detail do |answer, metric, detail|
          answer.card.format.answer_accordion_item metric, detail
        end
      end
    end
  end

  view :core, :expanded_details

  def calculation_only
    card.researched? ? "" : yield
  end

  def overridden_answer_with_formula
    overridden_answer if overridden_value?
  end

  def overridden_answer
    value = card.answer.overridden_value
    value = humanized_number value if card.metric_type.to_sym == :formula
    wrap_with(:div, class: "overridden-answer metric-value") { value }
  end
end
