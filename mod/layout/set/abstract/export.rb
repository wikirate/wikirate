format :html do
  def export_formats
    [:csv, :json]
  end

  view :export_links do
    wrap_with :p do
      "Export: #{format_links}"
    end
  end

  def format_links
    export_formats.map do |format|
      link_to_card card, format, path: export_link_path(format)
    end.join " / "
  end

  def export_link_path format
    { format: format }
  end
end
