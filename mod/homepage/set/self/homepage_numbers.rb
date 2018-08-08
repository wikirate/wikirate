include_set Abstract::HamlFile

format :html do
  Category = Struct.new "Category", :codename, :title, :count, :color, :icon

  def categories
    [
      category(:wikirate_company, "Companies", :companies),
      category(:metric, "Metric questions", :metric, :help),
      category(:metric_answer, "Metric Answers", :metric, :check),
      category(:source, "Sources", :source)
    ]
  end

  def category codename, title, color, icon=icon_map(codename)
    Category.new codename, title, count(codename), color, icon
  end

  def featured_answers
    Card[:featured_answers].item_names
  end

  def count card_type
    number = nest card_type, view: :count
    number_with_delimiter(number, delimiter: ",")
  end
end
