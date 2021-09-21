# project and dataset names got screwed up on the live site after the add_dataset
# migration (presumably due to some issues that led to the deployment script being
# run multiple times).

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

def drop_research_prefices name
  name.sub(/^(Research: )+/, "")
end

def fix_project project
  return unless project
  puts "fix project: #{project.name}"

  dataset_field = project.field :dataset
  dataset_field.update! content: drop_research_prefices(dataset_field.first_name)
  project.update! name: "Research: #{drop_research_prefices project.name}"
end

Card.where("type_id = #{Card::DatasetID} and name like 'Research:%'").each do |dataset|
  root_name = drop_research_prefix dataset.name
  next unless root_name != dataset.name && Card.exist?(root_name)

  dataset.include_set_modules

  fix_project dataset.fetch(:project)&.first_card
  puts "fix delete dataset: #{dataset.name}"
  dataset.delete!
end
