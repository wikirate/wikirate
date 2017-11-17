def csv?
  file.content_type.in? ["text/csv", "text/comma-separated-values"]
end
