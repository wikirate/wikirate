# including module must respond to
# A) `fixed_field`, returning a Symbol representing an AnswerQuery id filter, and
# B) `filter_card_fieldcode`, returning the codename of the filter field

include_set Abstract::Table
include_set Abstract::Utility
include_set Abstract::BrowseFilterForm

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
  AnswerQuery.new filter_hash, sort_hash, paging
end

def override_filter_hash hash
  @default_filter_hash = hash
end

def default_filter_hash
  @default_filter_hash ||= {}
end

def item_type
  "Answer" # :metric_answer.cardname
end

format :csv do
  view :core do
    Answer.csv_title + card.query.answer_query.map(&:csv_line).join
  end
end

format :html do
  delegate :partner, to: :card

  def export_formats
    %i[csv json]
  end

  view :filtered_content do
    card.override_filter_hash default_filter_hash
    super() + raw('<div class="details"></div>')
  end

  def default_filter? field
    default_filter_hash.key? field
  end

  view :core, cache: :never, template: :haml

  view :table, cache: :never do
    wrap true, "data-details-view": details_view do
      wikirate_table table_type, self, cell_views, header: header_cells,
                                                   td: { classes: %w[header data] },
                                                   tr: { method: :tr_attribs }
    end
  end

  def table_type
    :metric_answer
  end

  view :answer_header, cache: :never do
    [table_sort_link("Answer", :value, "pull-left mx-3 px-1"),
     table_sort_link("Year", :year, "pull-right mx-3 px-1")]
  end

  def tr_attribs row_card
    return {} unless row_card.known?

    { class: "details-toggle", "data-details-mark": row_card.name.url_key }
  end
end
