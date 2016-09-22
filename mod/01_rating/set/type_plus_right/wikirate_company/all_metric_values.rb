include_set Abstract::AllMetricValues

def wql_to_identify_related_metric_values
  '"left": { "right":"_left" }'
end

def user_voted_metric votee_type
  votee_search = "#{Auth.current.name}+metric+#{votee_type}_search"
  Card.fetch(votee_search).item_names
end

format do
  def num?
    false
  end
end

format :html do
  def page_link_params
    [:name, :wikirate_topic, :research_policy, :vote, :value, :type,
     :year, :sort]
  end

  view :card_list_items do |args|
    search_results.map do |row|
      c = Card.fetch "#{row[0]}+#{card.cardname.left}"
      render :card_list_item, args.clone.merge(item_card: c)
    end.join "\n"
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

  view :metric_list do |_args|
    wrap_with :div, class: "yinyang-list" do
      render_content(hide: "title",
                     items: { view: :metric_row })
    end
  end
end
