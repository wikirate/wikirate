include_set Abstract::SourceSearch

# cache # of sources tagged with this company (=left) via <source>+company
include_set Abstract::ListRefCachedCount,
            type_to_count: :source,
            list_field: :company

format do
  # don't show answer sort option, because that means "total answer"
  # users are likely to interpret answer as meaning answer for current company
  def sort_options
    super.reject { |_k, v| v == :answer }
  end
end
