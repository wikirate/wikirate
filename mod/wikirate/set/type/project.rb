card_reader :wikirate_company
card_reader :metric
card_reader :organizer

format :html do
  view :row do
    bs_layout do
      row 2, 10 do
        column { field_nest :image, size: :small }
        column { row_details }
      end
    end
  end

  def row_details
    output [
      wrap_with(:h4, _render_title),
      wrap_with(:div, organizational_details),
      wrap_with(:div, stats_details),
      wrap_with(:div, topics_details)
    ]
  end

  def organizational_details
    [
      field_nest(:wikirate_status, items: { view: :name }),
      "organized by #{field_nest :organizer, items: { view: :link }}"
    ].join " | "
  end

  def stats_details
    [ count_stats,


    ].join
  end

  def count_stats
    [
      "#{card.wikirate_company_card.item_names.size} Companies",
      "#{card.metric_card.item_names.size} Metrics"
    ].join ", "
  end

  def topics_details
    field_nest :wikirate_topic, items: { view: :link, type: "Topic" }
  end
end
