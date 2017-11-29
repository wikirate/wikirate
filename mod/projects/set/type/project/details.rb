format :html do

  # left column content
  def project_details
    wrap_with :div do
      [
          field_nest(:organizer,
                     view: :titled,
                     title: "Organizer",
                     items: { view: :thumbnail_plain }),
          standard_pointer_nest(:wikirate_topic),
          field_nest(:description, view: :titled, title: "Description"),
          field_nest(:conversation,
                     view: :project_conversation, title: "Conversation")
      ]
    end
  end

  view :listing do
    image = card.field(:image)
    title = _render_link
    text = row_details
    bs_layout do
      row 12, class: "project-summary" do
        col text_with_image(image: image, size: :medium,
                            title: title, text: text)
      end
    end
  end

  def row_details
    wrap_with :div, class: "project-details-info" do
      [
          wrap_with(:div, class: "organizational-details") do
            organizational_details
          end,
          wrap_with(:div, class: "stat-details overall-progress-box") do
            stats_details
          end,
          wrap_with(:div, topics_details, class: "topic-details")
      ]
    end
  end

  def organizational_details
    organized_by = wrap_with :div, class: "organized-by horizontal-list" do
      [
          wrap_with(:span, " | organized by "),
          field_nest(:organizer, items: { view: :link })
      ]
    end
    status = field_nest(:wikirate_status, items: { view: :name })
    [status, organized_by]
  end

  def stats_details
    "#{count_stats} #{card.percent_researched}% #{overall_progress_bar}"
  end

  def count_stats
    wrap_with :span do
      "#{card.num_companies} Companies, #{card.num_metrics} Metrics | "
    end
  end

  def topics_details
    wrap_with :div, class: "horizontal-list" do
      field_nest :wikirate_topic, items: { view: :link, type: "Topic" }
    end
  end
end