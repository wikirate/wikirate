format :html do
  def sort_options
    handling_fulltext do
      # TODO: make it possible to use super here
      { "Alphabetical": :name, "Recently Added": :create }
    end
  end

  # This only shows relevance sorting when the page is loaded with an explicit
  # fulltext prefix (:) in the name search. Otherwise "relevance" sorting doesn't
  # make sense.
  def handling_fulltext
    options = yield
    add_sort_by_relevance options if fulltext_name_filtering?
    options
  end

  def add_sort_by_relevance options
    options["Relevance"] = :relevance
    params[:sort] = :relevance unless sort_param
  end

  def fulltext_name_filtering?
    params.dig(:filter, :name)&.match?(/^\:/)
  end
end
