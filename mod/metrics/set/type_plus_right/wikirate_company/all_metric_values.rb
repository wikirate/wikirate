include_set Abstract::AllMetricValues

def query_class
  FixedCompanyAnswerQuery
end

def default_sort_option
  :importance
end

format do
  def page_link_params
    [:wikirate_topic, :vote, :value,]

  end
end
format :html do
  def item_card_from_row row
    Card.fetch "#{row[0]}+#{card.cardname.left}"
  end

  view :card_list_header do
    <<-HTML
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          <div class='metric-list-header slotter header'>
            Metrics
          </div>
          <div class='metric-list-header slotter data'>
            Values
          </div>
        </div>
      </div>
    HTML
  end
end
