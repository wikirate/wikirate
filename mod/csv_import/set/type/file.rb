def csv?
  attachment.content_type.in? %w[text/csv
                                 text/comma-separated-values
                                 text/plain
                                 text/x-csv
                                 text/x-comma-separated-values
                                 application/vnd.ms-excel
                                 application/csv
                                 application/x-csv]
end
