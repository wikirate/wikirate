format :html do
  view :core, template: :haml do
    @categories = [:company, :topic, :metric]
  end
end
