format :html do
  def export_formats
    [:csv, :json]
  end

  view :export_links, cache: :never do
    wrap_with :p do
      "Export: #{export_format_links}"
    end
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
