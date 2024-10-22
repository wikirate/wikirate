include_set Abstract::Slider

view :company_slider, template: :haml, cache: :yes

def companies_for_slider
  raise "override me"
end
