format :html do
  view :open_content do |args|
    bs_layout container: false, fluid: true, class: @container_class do
      row 5, 7, class: "panel-margin-fix" do
        column _render_content_left_col, args[:left_class]
        column _render_content_right_col, args[:right_class]
      end
    end
  end

  def default_content_formgroup_args _args
    voo.edit_structure =
        [
            :image,
            :organizer,
            :wikirate_topic,
            :description,
            :metric,
            :wikirate_company
        ]
  end

  def header_right
    wrap_with :div, class: "header-right" do
      [
          wrap_with(:h3, _render_title, class: "project-title"),
          field_nest(:wikirate_status, view: :labeled)
      ]
    end
  end

  view :data do
    wrap_with :div, class: "project-details" do
      left_col_content
    end
  end

  def left_col_content
    wrap_with :div do
      [
          field_nest(:organizer,
                     view: :titled,
                     title: "Organizer",
                     items: { view: :thumbnail_plain }),
          field_nest(:wikirate_topic,
                     view: :titled,
                     title: "Topics",
                     items: { view: :link }),
          field_nest(:description, view: :titled, title: "Description"),
          field_nest(:conversation,
                     view: :project_conversation, title: "Conversation")
      ]
    end
  end

  view :content_right_col do
    wrap_with :div, class: "progress-column" do
      [overall_progress_box, _render_tabs, _render_export_links]
    end
  end

  def tab_list
    {
        company_list_tab: "#{card.num_companies} Companies",
        metric_list_tab: "#{fa_icon 'bar-chart'} #{card.num_metrics} Metrics"
    }
  end

  view :metric_list_tab do
    standard_pointer_nest :metric
  end

  view :company_list_tab do
    standard_pointer_nest :wikirate_company
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
