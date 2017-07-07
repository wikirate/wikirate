include_set Type::File
include_set Abstract::Import

attachment :relationship_answer_import_file, uploader: CarrierWave::FileCardUploader


# @return updated or created metric value card object
def parse_import_row import_data, source_map
  args = process_data import_data
  process_source args, source_map
  return unless valid_value_data? args
  return unless ensure_company_exists args[:company], args
  return unless ensure_company_exists args[:related_company], args
  return unless (create_args = construct_value_args args)
  check_duplication_in_subcards create_args[:name], args[:row]
  return if check_duplication_with_existing create_args[:name], args[:source]
  add_subcard create_args.delete(:name), create_args
end

format :html do
  def data_related_company data
    if data[:wikirate_related_company].empty?
      data[:file_related_company]
    else
      data[:wikirate_related_company]
    end
  end

  def prepare_import_row_data row, index
    data = row_to_hash row
    data[:csv_row_index] = index
    data[:wikirate_company], data[:status] = find_wikirate_company data[:file_company]
    data[:wikirate_related_company], related_status = find_wikirate_company data[:file_related_company]
    data[:status] = [data[:status], related_status].min.to_s
    data[:company] = data_company data
    data[:related_company] = data_related_company data
    data
  end

  def default_import_table_args args
    args[:table_header] = ["Select", "#", "Metric",
                           "Company in File", "Company in Wikirate",
                           "Correction",
                           "Related Company in File", "Related Company in Wikirate",
                           "Correction",
                           "Year", "Value", "Source", "Comment"]
    args[:table_fields] = [:checkbox, :row, :metric, :file_company,
                           :wikirate_company, :correction,
                           :file_related_company,
                           :wikirate_related_company, :related_correction,
                           :year, :value, :source, :comment]
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
      headline = "Relationships exist and are not modified."
      msg += duplicated_value_warning_message headline, identical_metric_values
    end
    if (duplicated_metric_values = Env.params[:duplicated_metric_value])
      headline = "Relationships exist with different source and are not "\
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

  def import_fields
    [:metric, :file_company, :file_related_company, :year, :value, :source, :comment]
  end
end