def merge_into target_metric
  move_all_answers_to target_metric
  move_project_listings_to target_metric
end

def move_all_answers_to target_metric
  all_answers.each do |answer|
    next unless answer.real?
    answer.move metric: target_metric
  end
end

def move_project_listings_to target_metric
  replace_metric_listings :project, target_metric do |met_proj|
    Card[met_proj.right] # each item is <metric>+<project>
  end
end

def move_source_listings_to target_metric
  replace_metric_listings(:source, target_metric) { |source| Card[source] }
end

def replace_metric_listings trait, target_metric
  fetch(trait: trait).item_names.each do |trait|
    next unless base = yield(trait)

    replace_metric_in_list base, target_metric
  end
end

def replace_metric_in_list base, target_metric
  list = base.fetch trait: :metric
  list.drop_item name
  list.add_item target_metric
  list.save
end
