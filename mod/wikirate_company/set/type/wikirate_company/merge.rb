# the following is WIP code developed for the single-use script fashion_merge.rb.
# It is not ready for primetime.

def merge_into target_company
  target_company = Card.fetch_name target_company
  move_all_answers_to target_company
  move_project_listings_to target_company
  move_group_listings_to target_company
  # delete!
end

def move_all_answers_to target_company
  all_answers.each do |answer|
    next unless answer.real?
    answer.move company: target_company
  end
end

def move_project_listings_to target_company
  fetch(trait: :project).item_names.each do |comp_proj|
    project = Card[comp_proj.right] # each item is <company>+<project>
    replace_company_in_list project, target_company
  end
end

def move_group_listings_to target_company
  fetch(trait: :company_group).item_names.each do |company_group|
    next unless company_group.specification_card.explicit?
    replace_company_in_list company_group, target_company
  end
end

def replace_company_in_list base, target_company
  list = base.fetch trait: :wikirate_company
  list.drop_item name
  list.add_item target_company
  list.save
end
