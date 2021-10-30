include_set Abstract::HamlFile

format :html do
  Category = Struct.new :codename, :title, :count, :color

  def categories
    [
      category(:wikirate_company, rate_subjects, :company),
      category(:metric, "Metric Questions", :metric),
      category(:metric_answer, "Metric Answers", :answer),
      category(:source, "Sources", :source)
    ]
  end

  def category codename, title, color
    Category.new codename, title, count(codename), color
  end

  def featured_answers
    Card[%i[metric_answer featured]].item_names
  end

  def count card_type
    nest card_type, view: :count
  end
end
