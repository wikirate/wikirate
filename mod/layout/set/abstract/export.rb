format :html do
  def export_formats
    [:csv, :json]
  end

  view :export_links do
    render_haml do
      <<-HAML.strip_heredoc
        %p
          Export:
          = format_links
      HAML
    end
  end

  def format_links
    export_formats.map do |f|
      link_to_card card, f, path: { format: f }
    end.join " / "
  end
end
