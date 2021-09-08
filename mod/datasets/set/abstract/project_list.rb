delegate :dataset_name, to: :project_card

def project_name
  name.left_name
end

def project_card
  left
end

format :html do
  before :filtered_content do
    voo.hide :menu
    voo.items = { view: :bar, hide: :bar_nav }
  end
end
