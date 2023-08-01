
card_accessor :adaptation, type: :pointer
card_accessor :party, type: :phrase
card_accessor :url, type: :uri
card_accessor :wikirate_title, type: :phrase

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
