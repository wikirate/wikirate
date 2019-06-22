# including module must respond to
# A) `fixed_field`, returning a Symbol representing an AnswerQuery id filter, and
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
  when :name  then q.run.map(&:name)
  when :count then q.count
  else             q.run
  end
end

def query paging={}
  filter = filter_hash.merge fixed_field => left.id
  AnswerQuery.new filter, sort_hash, paging
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
    wrap true, "data-details-view": details_view, home_view: "table" do
      wikirate_table partner, self, cell_views, { header: header_cells,
                                                  td: { classes: %w[header data] },
                                                  tr: { method: :tr_attribs } }
    end
  end

  view :answer_header do
    [table_sort_link("Answer", :value, "pull-left mx-3 px-1"),
     table_sort_link("Year", :year, "pull-right mx-3 px-1")]
  end

  def tr_attribs row_card
    return {} unless row_card.known?

    { class: "details-toggle", "data-details-mark": row_card.name.url_key }
  end
end
