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
    tabs["Sources"] = sources_tab if metric? && company?
    tabs["Methodology"] = metric_details_tab if metric?
    tabs["Help"] = nest :how_to_research, view: :content
    static_tabs tabs, active_tab, "tabs", pane: { class: "p-3" }
  end

  def cite_mode?
    answer_card.unknown? ||
      @answer_view.in?(%i[research_edit_form research_form])
  end

  def hide_view_source_tab?
    cite_mode? || !existing_answer_with_source?
  end

  def sources_tab
    project # make sure instance variable is set
    nest answer_card, view: :source_tab
  end

  # def view_source_tab hide: false
  #   hide_tab _render_source_preview_tab, hide
  # end

  def metric_details_tab
    nest metric, view: :main_details,
                 hide: [:add_value_buttons, :import_button, :about]
  end
end
