include_set Abstract::Slider

view :company_slider, template: :haml

def companies_for_slider
  raise "override me"
end
