include_set Abstract::Table
include_set Abstract::BrowseFilterForm

def item_type
  "Answer" # :metric_answer.cardname
end

# shared search method for card and format
def search args={}
  return_type = args.delete :return
  query = args.delete(:query) || query(args)
  run_query_returning query, return_type
end

def run_query_returning query, return_type
  case return_type
  when :name  then query.run.map(&:name)
  when :count then query.count
  else             query.run
  end
end

def query paging={}
  AnswerQuery.new({}, {}, paging)
end

format do
  def filter_hash_from_params
    super.tap do |h|
      normalize_filter_hash h if h
    end
  end

  def search_with_params
    card.search query: query
  end

  def count_with_params
    card.search query: query, return: :count
  end

  def query
    AnswerQuery.new query_hash, sort_hash, paging_params
  end

  # note: overridden in fixed
  def query_hash
    filter_hash || {}
  end

  def card_content_limit
    nil
  end

  def normalize_filter_hash hash
    %i[metric company].each do |type|
      next unless (id = hash.delete :"#{type}_id")&.present?
      hash[:"#{type}_name"] = "=#{id.to_i.cardname}"
    end
  end
end

format :csv do
  view :core do
    Answer.csv_title + query.answer_lookup.map(&:csv_line).join
  end
end

format :html do
  delegate :partner, to: :card

  def export_formats
    %i[csv json]
  end

  view :filtered_content do
    super() + raw('<div class="details"></div>')
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
    [table_sort_link("Answer", :value, "float-left mx-3 px-1"),
     table_sort_link("Year", :year, "float-right mx-3 px-1")]
  end

  def tr_attribs row_card
    return {} unless row_card.known?

    { class: "details-toggle", "data-details-mark": row_card.name.url_key }
  end
end
