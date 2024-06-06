include_set Abstract::CompanyGroupSearch

format :html do
  before(:filtered_content) { voo.items[:view] = :box }
end
