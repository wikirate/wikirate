include_set Abstract::Header

format :html do
  def tab_list
    %i[details metric]
  end

  view :source_details, template: :haml

  view :details_tab do
    tab_wrap do
      _render_source_details
    end
  end

  view :metric_tab do
    tab_wrap do
      field_nest "metric_search", view: :content
    end
  end

  def download_tab_link
    case card.source_type_codename
    when :wikirate_link
      tab_link preview_url, "external-link-square", " Visit Original"
    when :file
      tab_link card.file_card.attachment.url, :download, " Download"
    else
      ""
    end
  end

  def tab_link url, icon, title
    icon = fa_icon icon
    title = icon + title
    link_to title, href: url, target: "_blank", class: "nav-link"
  end
end
