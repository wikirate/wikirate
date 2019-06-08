# including module must respond to
# A) `query_class`, returning a valid AnswerQuery class, and
# B) `filter_card_fieldcode`, returning the codename of the filter field

include_set Abstract::Table
include_set Abstract::Utility
include_set Abstract::BrowseFilterForm

def virtual?
  new?
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
  view :filtered_content do
    # this sets the default filter search options to match the default filter UI,
    # which is managed by the filter_card
    filter_hash.reverse_merge! card.filter_card.default_filter_option
    super() + raw('<div class="details-slot"></div>')
  end

  view :core, cache: :never, template: :haml

  view :filter_form do
    nest card.filter_card, view: :core
  end

  view :table, cache: :never do
    wrap true, "data-details-view": details_view do
      wikirate_table(*table_args)
    end
  end

  def td_args
    { classes: %w[header data] }
  end
end
