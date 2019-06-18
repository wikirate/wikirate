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
    super() + raw('<div class="details"></div>')
  end

  # can't just set default_filter_hash, because +answer doesn't default to most
  # recent year in csv or json format (or for answer counts)
  before :content do
    return if Env.params[:filter]

    filter_hash.merge! card.filter_card.default_filter_hash
  end

  view :core, cache: :never, template: :haml

  view :filter_form do
    nest card.filter_card, view: :core
  end

  view :table, cache: :never do
    wrap true, "data-details-view": details_view do
      args = table_args
      args.last.merge! td: { classes: %w[header data] },
                       tr: { method: :tr_attribs }
      wikirate_table(*args)
    end
  end

  def tr_attribs row_card
    if row_card.known?
      { class: "details-toggle", "data-details-mark": row_card.name.url_key }
    else
      {}
    end
  end
end
