WL_FORMULA_WHITELIST = ::Set.new ['Boole']

def metric_name
  cardname.left
end

def metric_id
  left_id
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

event :update_scores_for_formula, on: :update, after: :store,
                         when: proc { |c| !c.supercard } do # don't update if it's part of scored metric update
  left.update_scores
end

event :create_scores_for_formula, on: :create, after: :store,
                         when: proc { |c| !c.supercard } do # don't update if it's part of scored metric create
  left.create_scores
end