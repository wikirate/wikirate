
format :html do
  def extract_metric_card
    # Target+Henry_Tai+sinlundan+yinyang_drag_item

    # Target+Amnesty_International+Conflict_Minerals_Report+Henry_Tai
    # +yinyang_drag_item

    # Apple_Inc_+Natural_Resource_Use+Richard_Mills+Publishes_Smelters_Refiners
    # +yinyang_drag_item

    # Target+Natural_Resource_Use+Amnesty_International+Conflict_Minerals_Report
    # +Henry_Tai+yinyang_drag_item
    [card[1..3],  card[2..4], card[1..2], card[2..3]].each do |metric|
      return metric if metric && metric.type_code == :metric
    end
    nil
  end

  def default_content_args args
    if metric_card && metric_card.metric_type_codename == :score
      if card[0].type_code == :wikirate_topic
        args[:structure] = 'topic_score_metric_drag_item'
      elsif card[0].type_code == :wikirate_company
        args[:structure] = 'company_score_metric_drag_item'
      end
    end
  end
end
