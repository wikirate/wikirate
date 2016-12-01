include_set Abstract::AllMetricValues

def item_cards _args={}
  @item_cards ||= filtered_item_cards filter_hash, sort_hash, paging_hash
end

def filtered_item_cards filter={}, sort={}, paging={}
  CompanyBasedAnswerQuery.default left.id unless filter.present?
  CompanyBasedAnswerQuery.new(left.id, filter, sort, paging).run
end

format :html do
  view :card_list_header do
    <<-HTML
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          #{sort_link "Companies #{sort_icon :name}",
                      sort_by: 'name', sort_order: toggle_sort_order(:name),
                      class: 'header'}
          #{sort_link "Values #{sort_icon :value}",
                      sort_by: 'value', sort_order: toggle_sort_order(:value),
                      class: 'data'}
        </div>
      </div>
    HTML
  end

  def item_card_from_row row
    Card.fetch "#{card.cardname.left}+#{row[0]}"
  end
end
