include_set Abstract::LazyAccordion

# The answers that a calculated answer depends on
# @return [Array] array of Answer objects
def direct_dependee_answers
  direct_dependee_answer_map.flatten.uniq
end

def direct_dependee_map
  when_dependee_applicable { metric_card.calculator.answers_for company, year }
end

def dependee_answers
  direct_dependee_answers.tap do |answers|
    answers << answers.map(&:dependee_answers)
    answers.flatten!.uniq!
  end
end

def researched_dependee_answers
  dependee_answers.select(&:researched_value?)
end

def each_dependee_answer &block
  direct_dependee_answers.each do |answer|
    yield answer
    answer.each_dependee_answer(&block)
  end
end

# note: cannot do this in a single answer query, because it's important that we not skip
# over direct dependencies.
def each_depender_answer
  metric_card.each_depender_metric do |metric|
    answer = Answer.where(metric_id: metric, company_id: company_id, year: year).take
    yield answer if answer.present?
  end
end

def depender_answers
  [].tap do |answers|
    each_depender_answer do |answer|
      answers << answer
    end
  end
end

def when_dependee_applicable
  researched_value? || !metric_card ? [] : yield
end

def map_input_answer_and_detail
  input_answers = direct_dependee_map
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
      accordion_item title, body: stub_view(:calculation_details)
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
        card.map_input_answer_and_detail do |answers, metric, detail|
          input_accordion_items answers, metric, detail
        end
      end
    end
  end

  view :core, :expanded_details

  def calculation_only
    card.researched? ? "" : yield
  end

  private

  # usually only one, but can be many
  def input_accordion_items answers, metric, detail
    output do
      answers.flatten.map do |answer|
        answer.card.format.answer_accordion_item metric, detail
      end
    end
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
