include_set Abstract::Export

format :html do
  def export_views
    :titled
  end
end

format :csv do
  view :titles do
    ["Researcher Name",
     "Answers Created", "Answers Updated", "Answers Discussed", "Answers Checked"]
  end

  view :core do

  end
end