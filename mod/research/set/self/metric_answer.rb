format :html do
  view :imported_count do
    Answer.where(imported: true).count
  end
end

# format :csv do
#   view :core do
#     Answer.csv_title + Answer.all.map(&:csv_line).join
#   end
# end
