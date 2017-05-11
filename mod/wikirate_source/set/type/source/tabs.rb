format :html do
  def tab_list
    {
      details_tab: "#{fa_icon :info} Details",
      metrics_tab: "#{fa_icon 'bar-chart'} #{metric_count} Metrics",
      notes_tab: "#{fa_icon 'quote-left'} Notes",
      download_tab: { html: download_tab_link }
    }
  end
  view :source_details, template: :haml
  view :details_tab do
    tab_wrap do
      _render_source_details
    end
  end
  view :metrics_tab do
    tab_wrap do
      field_nest "metric_search", view: :content
    end
  end
  view :notes_tab do
    tab_wrap do
      field_nest "source_note_list", view: :content
    end
  end

  def download_tab_link
    case card.source_type_codename
    when :wikirate_link
      tab_link preview_url, "external-link-square", " Visit Original"
    when :file
      tab_link file_card.attachment.url, :download, " Download"
    else
      ""
    end
  end

  def tab_link url, icon, title
    icon = fa_icon icon
    title = icon + title
    link_to title, href: url, target: "_blank"
  end
end
