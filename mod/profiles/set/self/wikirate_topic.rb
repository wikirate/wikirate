def subvariants
  {
    voted_on: [:voted_for, :voted_against]
  }
end

format :html do
  view :core, template: :haml
end
