include_set Type::File
include_set Abstract::Import

attachment :metric_value_import_file, uploader: CarrierWave::FileCardUploader

format :html do
  def default_import_table_args args
    args[:table_header] = ["Select", "#", "Metric",
                           "Company in File", "Company in Wikirate",
                           "Correction",
                           "Year", "Value", "Source", "Comment"]
    args[:table_fields] = [:checkbox, :row, :metric, :file_company,
                           :wikirate_company, :correction,
                           :year, :value, :source, :comment]
  end

  def default_import_args args
    voo.hide :metric_select, :year_select
  end

  view :import_success do |args|
    structure = "source item preview"
    redirect_content = _render_content args.merge(structure: structure)
    content_tag(:div, content_tag(:div, redirect_content,
                                  { class: "redirect-notice" }, false),
                { id: "source-preview-iframe",
                  class: "webpage-preview non-previewable" },
                false)
  end

  def contruct_import_warning_message args
    msg = ""
    if (identical_metric_values = args[:identical_metric_value])
      headline = "Metric values exist and are not modified."
      msg += duplicated_value_warning_message headline, identical_metric_values
    end
    if (duplicated_metric_values = args[:duplicated_metric_value])
      headline = "Metric values exist with different source and are not "\
                 "modified."
      msg += duplicated_value_warning_message headline, duplicated_metric_values
    end
    msg
  end

  view :core do |args|
    content = contruct_import_warning_message args
    content << handle_source do |source|
      <<-HTML
        <a href=\"#{source}\">Download #{showname voo.title}</a><br />
      HTML
    end.html_safe
    import_link = <<-HTML
      <a href=\"/#{card.cardname.url_key}?view=import\">Import ...</a>
    HTML
    content << import_link.html_safe
  end

  def import_fields
    [:metric, :file_company, :year, :value, :source, :comment]
  end
end
