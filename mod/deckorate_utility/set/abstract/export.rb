format do
  def export_filename
    "WikiRate-#{export_timestamp}-#{export_title}"
  end
end

format :html do
  view :export_panel, cache: :never, template: :haml
end