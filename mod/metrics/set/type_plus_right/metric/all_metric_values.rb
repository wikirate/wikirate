include_set Abstract::AllMetricValues

def query_class
  FixedMetricAnswerQuery
end

def default_sort_option
  :value
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
