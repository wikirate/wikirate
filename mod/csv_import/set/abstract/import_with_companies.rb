include_set Abstract::Import

format :html do
  # FIXME: separted this better
  #   a lot of dupliction with #table_rows
  #
  def row_buckets
    buckets = CompanyMatcher::MATCH_TYPE_ORDER.each_with_object({ invalid: [] }) do |(k, v), h|
      h[k] = []
    end
    buckets[:imported] = []
  end

  def bucket_key table_row
    key = super
    key == :valid ? table_row.match_type : key
  end

  def matches_companies?
    card.csv_row_class.ancestors.include? CSVRow::CompanyImport
  end
end
