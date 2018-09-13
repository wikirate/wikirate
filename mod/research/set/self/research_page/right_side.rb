format :html do
  view :source_preview_tab, cache: :never do
    wrap do
      nest preview_source, { view: :source_and_preview },
           source_cited: cited_preview_source?,
           source_disabled: existing_answer_with_source?
    end
  end

  def right_side_tabs
    tabs = {}
    if answer?
      tabs["Source"] = cite_source_tab hide: !cite_mode?
      tabs["View Source"] = view_source_tab hide: hide_view_source_tab?
    end
    tabs["Methodology"] = metric_details_tab if metric?
    tabs["Need Help?"] = nest :how_to_research, view: :content
    static_tabs tabs, active_tab, "tabs", pane: { class: "p-3" }
  end

  def cite_mode?
    answer_card.unknown? || @answer_view == :research_edit_form
  end

  def hide_view_source_tab?
    cite_mode? || !existing_answer_with_source?
  end

  def cite_source_tab hide: false
    project # make sure instance variable is set
    hide_tab nest(answer_card, view: :source_tab), hide
  end

  def view_source_tab hide: false
    hide_tab _render_source_preview_tab, hide
  end

  def metric_details_tab
    nest metric, view: :main_details,
         hide: [:add_value_buttons, :import_button, :about]
  end

  def hide_tab tab, hide=false
    return tab unless hide

    { content: tab, button_attr: { class: "d-none" } }
  end
end