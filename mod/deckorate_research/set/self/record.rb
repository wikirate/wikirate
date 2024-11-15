format :html do
  view :imported_count do
    Record.where(imported: true).count
  end
end
