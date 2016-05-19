include_set Type::File
include_set Abstract::Import

attachment :metric_value_import_file, uploader: FileUploader

format :html do
  def default_import_table_args args
    args[:table_header] = ["Select", '#', "Metric",
                           "Company in File", "Company in Wikirate", "Match",
                           "Correction",
                           "Year", "Value", "Source", "Comment"]
    args[:table_fields] = [:checkbox, :row, :metric, :file_company,
                           :wikirate_company, :status, :correction,
                           :year, :value, :source, :comment]
  end

  def default_import_args args
    super args
    args.merge! optional_metric_select: :hide,
                optional_year_select: :hide
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
      msg += <<-HTML
        <h4><b>Metric values exist and are not modified.</b></h4>
        <ul><li>#{identical_metric_values.join('</li><li>')}</li> <br />
      HTML
    end
    if (duplicated_metric_values = args[:duplicated_metric_value])
      msg += <<-HTML
        <h4><b>Metric values exist with different source and are not modified.</b></h4>
        <ul><li>#{duplicated_metric_values.join('</li><li>')}</li><br />
      HTML
    end
    msg.empty? ? "" : alert("warning") { msg }
  end

  view :core do |args|
    content = contruct_import_warning_message args
    content << handle_source(args) do |source|
      <<-HTML
        <a href=\"#{source}\">Download #{showname args[:title]}</a><br />
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
