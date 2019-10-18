include_set Right::BrowseSourceFilter

format :html do
  # don't show answer sort option, because that means "total answers"
  # users are likely to interpret answers as meaning answers for current company
  def sort_options
    super.reject { |_k, v| v == :answer }
  end
end
