# this set is no longer used for the metric value sidebar views on metric
# company page (replaced with metric_record_list view).
# probably not needed any more but I'm not sure if it is used somewhere else

include_set Abstract::Table

format :html do
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
                slot: { company: card.cardname.left_name.tag,
                        metric: card.cardname.left_name.trunk } }
      }
    )
    timeline_head _render_modal_link(modal_link_args), "new"
  end

  view :timeline_header_buttons do
    btn_class = "btn btn-sm btn-default margin-12"
    btn_add_class = [btn_class, "_add_new_value", "btn-primary"].join(" ")
    path = card.left.field("metric_details").cardname.url_key
    target_str = ["[id='", path, "'] #methodology-info"].join("")
    metric_card_type = card.left.trunk.metric_type.downcase.to_sym
    btn_add =
      wrap_with(:a, "Add answer",
                  class: btn_add_class,
                  data: {
                    company: card.cardname.left_name.right_name.url_key,
                    metric: card.cardname.left_name.trunk_name.url_key,
                    toggle: "collapse-next",
                    parent: ".timeline-data",
                    collapse: ".metric_value_form_container"
                  }
                 )
    btn_methodology =
      wrap_with(:a, "View Methodology",
                  class: btn_class + " " + "_view_methodology",
                  data: {
                    toggle: "collapse",
                    target: target_str,
                    collapse: ".metric_value_form_container"
                  }
                 )
    return btn_add + btn_methodology if metric_card_type == :researched
    # btn_methodology
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
