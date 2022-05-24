def new_relic_label
  codename ? "browse_#{codename}" : super
end

format :html do
  view :add_link do
    add_link modal: false
  end

  view :add_button do
    add_link modal: false, class: "btn btn-secondary"
  end
end
