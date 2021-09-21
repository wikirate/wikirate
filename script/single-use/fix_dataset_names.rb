# project and dataset names got screwed up on the live site after the add_dataset
# migration (presumably due to some issues that led to the deployment script being
# run multiple times).

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

def drop_research_prefices name
  name.sub(/^(Research: )+/, "")
end

Card.where(
  "type_id = #{Card::DatasetID} and trash is false and name like 'Research:%'"
).each do |dataset|
  root_name = drop_research_prefices dataset.name
  next unless root_name != dataset.name && Card.exist?(root_name)

  dataset.include_set_modules

  projects << dataset.fetch(:project)&.first_card
  puts "delete dataset: #{dataset.name}"
  dataset.delete!
end

Card.where(
  "type_id = #{Card::ProjectID} and trash is false and name like 'Research: Research:%'"
).each do |project|
  dataset_field = project.field :dataset
  dataset_field.update! content: drop_research_prefices(dataset_field.first_name)
  puts "project id: #{project.id}"
  puts "new project name: Research: #{drop_research_prefices project.name}"
  project.update! name: "Research: #{drop_research_prefices project.name}"
end
