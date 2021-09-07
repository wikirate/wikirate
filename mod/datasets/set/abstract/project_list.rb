delegate :dataset_name, to: :project_card

def project_name
  name.left_name
end

def project_card
  left
end

# # card for searching/filtering through all companies/metrics when adding new items
# def filter_card
#   Card.fetch scope_code, filter_field_name
# end

format :html do
  # delegate :filter_card, to: :card

  def input_type
    card.count > 800 ? :list : :filtered_list
  end

  before :filtered_content do
    voo.hide :menu
    voo.items = { view: :bar, hide: :bar_nav }
  end
end
