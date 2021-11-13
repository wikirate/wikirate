include_set Abstract::SourceFilter

# cache # of sources tagged with this company (=left) via <source>+company
include_set Abstract::ListRefCachedCount,
            type_to_count: :source,
            list_field: :wikirate_company

format do
  # don't show answer sort option, because that means "total answers"
  # users are likely to interpret answers as meaning answers for current company
  def sort_options
    super.reject { |_k, v| v == :answer }
  end
end
