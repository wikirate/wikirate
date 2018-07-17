include_set Abstract::Search
include_set Abstract::Utility
include_set Abstract::Filter
include_set Abstract::FilterFormgroups

def virtual?
  true
end

# def limit
#   20
# end

format do
  def paging_view
    :content
  end
end

format :html do
  # view :card_list_items do
  #   search_with_params.map do |row|
  #     item_card = item_card_from_row row
  #     card_list_item item_card
  #   end.join "\n"
  # end
  #
  # view :card_list do
  #   paging = _render :paging
  #   if search_with_params.blank?
  #     render_no_search_results
  #   else
  #     results = render! :card_list_items
  #     header = render! :card_list_header
  #     %(
  #     #{paging}
  #     #{header}
  #       <div class="search-result-list">
  #         #{results}
  #       </div>
  #       #{paging if search_with_params.length > 10}
  #     )
  #   end
  # end
  #
  # view :card_list_header do
  #   ""
  # end
  #
  # def item_card_from_row row
  #   Card.fetch row[0]
  # end
end
