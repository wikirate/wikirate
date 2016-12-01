include_set Abstract::AllMetricValues

# def wql_to_identify_related_metric_values
#   '"left": { "right":"_left" }'
# end

def item_cards _args={}
  MetricAnswer.fetch(company_id: left.id, latest: true)
end

# def filtered_values_by_name
#   @filtered_values_by_name ||= MetricAnswer.filter filter_keys_with_values
# end

format do
  def page_link_params
    [:name, :wikirate_topic, :research_policy, :vote, :value, :type,
     :year, :sort]
  end

  def num?
    false
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

  # view :metric_list do |_args|
  #   wrap_with :div, class: "yinyang-list" do
  #     render_content(hide: "title",
  #                    items: { view: :metric_row })
  #   end
  # end
end
