include_set Abstract::Header
include_set Abstract::Tabs

format :html do
  before :content_formgroup do
    voo.edit_structure = %i[
      file
      wikirate_title
      report_type
      wikirate_company
      year
      wikirate_topic
      description
    ]
  end

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

  def original_link
    return unless card.link?
    link_with_icon card.link_url, "external-link-square", "Original"
  end

  def download_link
    link_with_icon card.file_url, :download, "Download"
  end

  def link_with_icon url, icon, title
    text = "#{fa_icon icon} #{title}"
    link_to text, href: url, target: "_blank", class: "source-color"
  end
end
