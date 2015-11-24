WL_FORMULA_WHITELIST = ::Set.new ['Boole']

def metric_name
  cardname.left
end

event :approve_formula, before: :approve do
  not_on_whitelist = content.gsub(/\{\{([^}])+\}\}/,'').scan(/[a-zA-Z][a-zA-Z]+/)
    .reject do |word|
      WL_FORMULA_WHITELIST.include? word
    end
  if not_on_whitelist.present?
    errors.add :formula, "#{not_on_whitelist.first} forbidden keyword"
  end
end

event :update_scores_for_formula, on: :update, before: :approve,
                         when: proc { |c| !c.supercard } do # don't update if it's part of scored metric update
  add_subcard left
  left.update_values
end

event :create_scores_for_formula, on: :create, before: :approve,
                         when: proc { |c| !c.supercard } do # don't update if it's part of scored metric create
  add_subcard left
  left.create_values
end