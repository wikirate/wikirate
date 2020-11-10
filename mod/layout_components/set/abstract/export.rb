format :html do
  def export_formats
    [:csv, :json]
  end

  view :export_links, cache: :never do
    return "" if export_formats.blank?

    wrap_with :div, class: "export-links py-3" do
      "Export: #{export_format_links}"
    end
  end

  view :filtered_results do
    class_up "card-slot", "_filter-result-slot"

    wrap { [render_core, render_export_links] }
  end

  def export_format_links
    export_formats.map { |format| export_format_link format }.join " / "
  end

  def export_format_link format
    link_to_card card, format, path: export_link_path(format)
  end

  def export_link_path format
    { format: format }
  end
end
