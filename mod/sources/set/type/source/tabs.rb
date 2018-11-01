include_set Abstract::Header

format :html do
  def tab_list
    %i[details metric metric_answer]
  end

  view :source_details, template: :haml

  view :details_tab do
    tab_wrap do
      _render_source_details
    end
  end

  view :metric_tab do
    tab_wrap do
      field_nest :metric, items: { view: :mini_bar }
    end
  end

  view :metric_answer_tab do
    tab_wrap do
      field_nest :metric_answer, items: { view: :mini_bar }
    end
  end

  def download_link
    case card.source_type_codename
    when :wikirate_link
      link_with_icon preview_url, "external-link-square", "Visit Original"
    when :file
      link_with_icon card.file_card.attachment.url, :download, "Download"
    else
      ""
    end
  end

  def link_with_icon url, icon, title
    text = "#{fa_icon icon} #{title}"
    link_to text, href: url, target: "_blank", class: "source-color"
  end
end
