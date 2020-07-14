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
    if params.dig(:filter, :name)&.match?(/^\:/) && !params[:sort]
      options["Relevance"] = :relevance
      params[:sort] ||= "relevance"
    end
    options
  end
end
