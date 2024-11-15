include_set Abstract::LazyTree

# The records that a calculated record depends on
# @return [Array] array of Record objects
def direct_dependee_records
  direct_dependee_map.flatten.uniq
end

def direct_dependee_map
  when_dependee_applicable { metric_card.calculator.records_for company, year }
end

def dependee_records
  direct_dependee_records.tap do |records|
    records << records.map(&:dependee_records)
    records.flatten!.uniq!
  end
end

def researched_dependee_records
  dependee_records.select(&:researched_value?)
end

def each_dependee_record &block
  direct_dependee_records.each do |record|
    yield record
    record.each_dependee_record(&block)
  end
end

# note: cannot do this in a single record query, because it's important that we not skip
# over direct dependencies.
def each_depender_record
  metric_card.each_depender_metric do |metric|
    record = ::Record.where(metric_id: metric, company_id: company_id, year: year).take
    yield record if record.present?
  end
end

def depender_records
  [].tap do |records|
    each_depender_record do |record|
      records << record
    end
  end
end

def when_dependee_applicable
  researched_value? || !metric_card ? [] : yield
end

def map_input_record_and_detail
  input_records_map = direct_dependee_map
  metric_card.input_metrics_and_detail.map.with_index do |(metric, detail), index|
    input_records = input_records_map[index]
    yield input_records, metric, detail if input_records.present?
  end
end

format :html do
  delegate :metric_card, to: :card

  view :expanded_details do
    if metric_card.researched?
      ""
    elsif card.overridden?
      overridden_record_with_formula
    else
      wrap_with(:div, class: "tree-top _tree-top") { render_calculation_details }
    end
  end

  def record_tree_item metric, detail, other_records=[]
    expandable = card.calculated? && other_records.empty?
    value = render_concise +
            output { other_records.map { |a| nest a.card, view: :concise } }

    wrap_record_tree_item expandable do
      metric.card.format.metric_tree_item_title detail: detail, record: value
    end
  end

  def wrap_record_tree_item expandable, &block
    if expandable
      tree_item yield, body: card_stub(view: :calculation_details)
    else
      wrap_with :div, class: "static-tree-item", &block
    end
  end

  view :calculation_details do
    calculation_only do
      [metric_card.format.algorithm, render_record_tree]
    end
  end

  view :record_tree do
    calculation_only do
      card.map_input_record_and_detail do |records, metric, detail|
        input_tree_item records, metric, detail
      end
    end
  end

  view :core, :expanded_details

  def calculation_only
    card.researched? ? "" : yield
  end

  private

  def input_tree_item records, metric, detail
    first_record = records.shift
    first_record.record.card.format.record_tree_item metric, detail, records
  end

  def overridden_record_with_formula
    overridden_record if overridden_value?
  end

  def overridden_record
    value = card.record.overridden_value
    value = humanized_number value if card.metric_type.to_sym == :formula
    wrap_with(:div, class: "overridden-record metric-value") { value }
  end
end
