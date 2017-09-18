include_set Type::File
include_set Abstract::Import

attachment :metric_value_import_file, uploader: CarrierWave::FileCardUploader

format :html do
  COLUMNS = [:checkbox, :row_index, :metric, :file_company,
                             :wikirate_company, :company_correction,
                             :year, :value, :source, :comment]
  COLUMN_TITLES = ["Select", "#", "Metric",
                             "Company in File", "Company in Wikirate",
                             "Correction",
                             "Year", "Value", "Source", "Comment"]
  def column_keys
    Card::Set::Type::MetricValueImportFile::COLUMNS
  end

  def column_titles
    Card::Set::Type::MetricValueImportFile::COLUMN_TITLES
  end

  def default_import_args _args
    voo.hide :metric_select, :year_select
  end

  view :import_success do
    wrap_with :div, id: "source-preview-iframe",
                    class: "webpage-preview non-previewable" do
      wrap_with :div, class: "redirect-notice" do
        _render_content structure: "source item preview"
      end
    end
  end

  def construct_import_warning_message
    msg = ""
    if (identical_metric_values = Env.params[:identical_metric_value])
      headline = "Metric values exist and are not modified."
      msg += duplicated_value_warning_message headline, identical_metric_values
    end
    if (duplicated_metric_values = Env.params[:duplicated_metric_value])
      headline = "Metric values exist with different source and are not "\
                 "modified."
      msg += duplicated_value_warning_message headline, duplicated_metric_values
    end
    msg
  end

  view :core do
    output [
      construct_import_warning_message,
      download_link,
      import_link.html_safe
    ]
  end


  def download_link
    handle_source do |source|
      %(<a href="#{source}" rel="nofollow">Download #{showname voo.title}</a><br />)
    end.html_safe
  end

  def import_link
    link_to_view :import, "Import ...", rel: "nofollow", remote: false
  end

  def csv_row_class
    MetricAnswerCSVRow
  end

  def import_fields
    [:metric, :file_company, :year, :value, :source, :comment]
  end
end
