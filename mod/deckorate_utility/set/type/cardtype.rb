include_set Abstract::DeckorateFiltering
include_set Abstract::SearchViews
include_set Abstract::Thumbnail

def item_type_id
  id
end

def new_relic_label
  codename ? "browse_#{codename}" : super
end

format :html do
  view :titled_content, template: :haml

  view :add_link do
    add_link modal: false
  end

  view :add_button do
    add_link modal: false, class: "btn btn-lg btn-primary"
  end
end
