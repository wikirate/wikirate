include_set Abstract::CompanyGroupFilter

format :html do
  before(:filtered_content) { voo.items[:view] = :box }
end
