include_set Abstract::HamlFile

format :html do
  def haml_locals
    { categories: [:company, :topic, :metric] }
  end

  def edit_fields
    [
      ["homepage companies", { absolute: true }],
      ["homepage topics", { absolute: true }],
      ["homepage metrics", { absolute: true }]
    ]
  end
end
