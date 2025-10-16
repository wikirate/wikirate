include_set Abstract::LazyTree

MAX_OTHER_ANSWERS = 5

# The answer that a calculated answer depends on
# @return [Array] array of Answer objects
def direct_dependee_answers
  direct_dependee_map.flatten.uniq
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
    answer = ::Answer.where(metric_id: metric, company_id: company_id, year: year).take
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
  input_answer_map = direct_dependee_map
  metric_card.input_metrics_and_detail.map.with_index do |(metric, detail), index|
    input_answers = input_answer_map[index]
    yield input_answers, metric, detail if input_answers.present?
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
      wrap_with(:div, class: "tree-top _tree-top") { render_calculation_details }
    end
  end

  def answer_tree_item metric, detail, other_answers=[]
    expandable = card.calculated? && other_answers.empty?
    value = answer_tree_answer(other_answers) { render_concise }

    wrap_answer_tree_item expandable do
      metric.card.format.metric_tree_item_title detail: detail, answer: value
    end
  end

  def answer_tree_answer other_answers
    return yield unless other_answers.any?

    output do
      other_answers[0..MAX_OTHER_ANSWERS]
        .map { |a| nest a.card, view: :concise }
        .unshift(yield)
        .push(answer_tree_remainder_answers(other_answers.size))
    end
  end

  def answer_tree_remainder_answers num_other_answers
    num_other_answers > 5 ? "and #{num_other_answers - 5} more..." : nil
  end

  def wrap_answer_tree_item expandable, &block
    if expandable
      tree_item yield, body: card_stub(view: :calculation_details)
    else
      wrap_with :div, class: "static-tree-item", &block
    end
  end

  view :calculation_details do
    calculation_only do
      [metric_card.format.algorithm, render_answer_tree]
    end
  end

  view :answer_tree do
    calculation_only do
      card.map_input_answer_and_detail do |answers, metric, detail|
        input_tree_item answers, metric, detail
      end
    end
  end

  view :core, :expanded_details

  def calculation_only
    card.researched? ? "" : yield
  end

  private

  def input_tree_item answers, metric, detail
    first_answer = answers.shift
    first_answer.answer.card.format.answer_tree_item metric, detail, answers
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
