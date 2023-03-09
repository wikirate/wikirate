include_set Abstract::Jumbotron

format :html do
  view :page do
    nest %i[policy type by_name], view: :core, items: { view: :box }
  end
end
