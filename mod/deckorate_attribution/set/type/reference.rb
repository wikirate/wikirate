
format :html do
  # def help_text
  #   "try me"
  # end

  def edit_fields
    [
      [:adaptation, title: "Adaptation"],
      [:party, title: "Person or Organization"],
      [:wikirate_title, title: "Title"],
      [:url, title: "URL"]
    ]
  end
end
