include_set Abstract::AllMetricValues

def wql_to_identify_related_metric_values
  '"left": { "left":"_left" }'
end

format do
  def page_link_params
    [:name, :industry, :project, :year, :value]
  end
end

format :html do
  view :card_list_header do
    <<-HTML
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          #{sort_link "Companies #{sort_icon :name}",
                      sort_by: 'name', order: toggle_sort_order(:name),
                      class: 'header'}
          #{sort_link "Values #{sort_icon :value}",
                sort_by: 'value', order: toggle_sort_order(:value),
                class: 'data'}
        </div>
      </div>
    HTML
  end

  def item_card_from_row row
    Card.fetch "#{card.cardname.left}+#{row[0]}"
  end
end
