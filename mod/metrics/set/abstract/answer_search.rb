include_set Abstract::SortAndFilter
include_set Abstract::Table

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
  if filter_hash.present?
    query_class.new left.id, filter_hash, sort_hash, args
  else
    query_class.default left.id, sort_hash, args
  end
end

format :html do
  view :core, cache: :never do
    merge_filter_defaults
    wrap_with :div, class: "filter-form-and-result nodblclick" do
      class_up "card-slot", "_filter-result-slot"
      output [_render_filter_form, _render_filter_result]
    end
  end

  view :filter_result, template: :haml, cache: :never

  view :filter_form do
    wrap_with :div, class: "row table-filter-container" do
      _render_filter
    end
  end

  view :filter do
    field_subformat(filter_card_fieldcode)._render_core
  end

  view :table, cache: :never do
    wrap do # slot for paging links
      wikirate_table_with_details(*table_args)
    end
  end

  # this sets the default filter search options to match the default filter UI.
  def merge_filter_defaults
    filter_hash.merge! filter_defaults
  end

  def filter_defaults
    card.field(filter_card_fieldcode).default_filter_option
  end

  def details_url? row_card
    !row_card.unknown?
  end

  def paging_view
    :table
  end
end
