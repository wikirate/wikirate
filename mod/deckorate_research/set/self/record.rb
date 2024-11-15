format :html do
  view :imported_count do
    Answer.where(imported: true).count
  end
end
