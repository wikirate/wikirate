# this set is no longer used for the metric value sidebar views on metric
# company page (replaced with metric_record_list view).
# probably not needed any more but I'm not sure if it is used somewhere else

include_set Abstract::Table
include_set Abstract::MetricChild, generation: 2

format :html do
  def fast_search_results
    Answer.fetch record_id: card.left.id
  end

  view :timeline, cache: :never do
    wrap_with :div, class: "timeline container" do
      wrap_with :div, class: "timeline-body" do
        wrap_with :div, class: "pull-left timeline-data" do
          [
            _optional_render(:timeline_header, column: :data),
            fast_search_results.map.with_index do |res, _i|
              subformat(res).render_timeline_data
            end
          ].flatten
        end
      end
    end
  end

  view :timeline_add_new_link do |args|
    modal_link_args = args.merge(
      link_text: "+ Add New Value",
      link_opts: {
        class: "btn btn-default btn-sm",
        path: { action: :new, mark: :metric_value,
                slot: { company: company_name.s,
                        metric: metric_name.s } }
      }
    )
    timeline_head _render_modal_link(modal_link_args), "new"
  end

  view :timeline_header_buttons do
    return unless metric_card.metric_type_codename == :researched
    output [add_answer_button, methodology_button]
  end

  view :record_list_header do
    voo.show :timeline_header_buttons
    wrap_with :div, class: "timeline-header timeline-row " do
      _optional_render_timeline_header_buttons
    end
  end

  def timeline_header_button text, klasses, data
    shared_data = { collapse: ".metric_value_form_container" }
    shared_classes = "btn btn-sm btn-default margin-12"
    wrap_with :a, text, class: css_classes(shared_classes, klasses),
                        data: shared_data.merge(data)
  end

  def add_answer_button
    timeline_header_button "Add answer",
                           "_add_new_value btn-primary",
                           company: company_name.url_key,
                           metric: metric_name.url_key,
                           toggle: "collapse-next",
                           parent: ".timeline-data"
  end

  def methodology_button
    target_id = record_name.to_name.url_key
    # TODO: add codename for "metric details" and convert to trait
    timeline_header_button "View Methodology",
                           "_view_methodology",
                           toggle: "collapse",
                           target: "[id='#{target_id}'] #methodology-info",
                           collapse: ".metric_value_form_container"

    #target: "[id='#{target_id}'] #methodology-info",
  end

  view :timeline_header do |args|
    voo.show :timeline_header_buttons
    wrap_with :div, class: "timeline-header timeline-row " do
      _optional_render_timeline_header_buttons if args[:column] == :data
    end
  end

  def timeline_head content, css_class
    wrap_with :div, content, class: "td #{css_class}"
  end
end
