# including module must respond to
# A) `query_class`, returning a valid AnswerQuery class, and
# B) `filter_card_fieldcode`, returning the codename of the filter field

include_set Abstract::Table
include_set Abstract::Search
include_set Abstract::Utility
include_set Abstract::Filter
include_set Abstract::FilterFormgroups

def virtual?
  true
end

def search args={}
  return_type = args.delete :return
  q = query(args)
  case return_type
  when :name then
    q.run.map(&:name)
  when :count then
    q.count
  else
    q.run
  end
end

def query args={}
  query_class.new left.id, filter_hash, sort_hash, args
end

def filter_card
  field filter_card_fieldcode
end

format :csv do
  view :core do
    Answer.csv_title + card.query(limit: nil).answer_lookup.map(&:csv_line).join
  end
end

format :html do
  view :core, cache: :never do
    merge_filter_defaults
    wrap_with :div, class: "filter-form-and-result nodblclick" do
      class_up "card-slot", "_filter-result-slot"
      output [_render_filter_form, _render_filter_result(home_view: :filter_result)]
    end
  end

  view :filter_result, template: :haml, cache: :never

  view :filter_form do
    wrap_with :div, class: "table-filter-container" do
      _render_filter
    end
  end

  view :filter do
    subformat(card.filter_card)._render_core
  end

  view :table, cache: :never do
    wikirate_table_with_details(*table_args)
  end

  # this sets the default filter search options to match the default filter UI,
  # which is managed by the filter_card
  def merge_filter_defaults
    filter_hash.merge! filter_defaults
  end

  def filter_defaults
    card.filter_card.default_filter_option
  end

  def details_url? row_card
    !row_card.unknown?
  end
end
