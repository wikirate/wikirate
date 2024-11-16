include_set Abstract::SourceSearch

# cache # of sources tagged with this company (=left) via <source>+company
include_set Abstract::ListRefCachedCount,
            type_to_count: :source,
            list_field: :company

format do
  # don't show record sort option, because that means "total records"
  # users are likely to interpret records as meaning records for current company
  def sort_options
    super.reject { |_k, v| v == :record }
  end
end
