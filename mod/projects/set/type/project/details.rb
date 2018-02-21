format :html do
  # ~~~~~~~~~~~~~ DETAILS ON PROJECT PAGE

  # left column content
  def project_details
    wrap_with :div do
      [
        field_nest(:organizer, view: :titled,
                               title: "Organizer",
                               items: { view: :thumbnail_plain }),
        standard_nest(:wikirate_topic),
        field_nest(:description, view: :titled, title: "Description"),
        field_nest(:conversation, view: :titled, title: "Conversation")
      ]
    end
  end

  # ~~~~~~~~~~~ DETAILS IN PROJECT LISTING

  view :listing do
    listing_layout do
      text_with_image image: card.field(:image),
                      size: :medium,
                      title: render_link,
                      text: listing_details
    end
  end

  def listing_layout
    bs_layout do
      row 12, class: "project-summary" do
        col yield
      end
    end
  end

  def listing_details
    wrap_with :div, class: "project-details-info" do
      [organizational_details, render_stats_details, topics_details]
    end
  end

  def organizational_details
    wrap_with :div, class: "organizational-details" do
      [organized_by_detail, status_detail]
    end
  end

  def organized_by_detail
    wrap_with :div, class: "organized-by horizontal-list" do
      [
        wrap_with(:span, " | organized by "),
        field_nest(:organizer, items: { view: :link })
      ]
    end
  end

  def status_detail
    field_nest :wikirate_status, items: { view: :name }
  end

  view :stats_details, cache: :never do
    wrap_with :div, class: "stat-details default-progress-box" do
      [
        count_stats,
        "#{card.percent_researched}%",
        research_progress_bar
      ].join " "
    end
  end

  def count_stats
    wrap_with :span do
      "#{card.num_companies} Companies, #{card.num_metrics} Metrics | "
    end
  end

  def topics_details
    wrap_with :div, class: "topic-details" do
      wrap_with :div, class: "horizontal-list" do
        field_nest :wikirate_topic, items: { view: :link, type: "Topic" }
      end
    end
  end
end
