# -*- encoding : utf-8 -*-

class AddDatasets < Cardio::Migration
  def up
    ensure_code_card "Data Set", codename: :dataset
    Card.search(type: :project) { |dataset| convert_to_dataset dataset }
    Card[:subproject]&.update! codename: :data_subset, name: "Data Subset"
  end

  def convert_to_dataset dataset
    dataset.update! type: "Data Set"
    project_name = "Research: #{dataset.name}"
    create_project project_name, dataset.name
    %i[organizer wikirate_status].each do |field|
      move_to_project project_name, dataset, field
    end
  end

  def create_project project_name, dataset_name
    Card.create! name: project_name,
                 type: :project,
                 subfields: { dataset: { type: :pointer, content: dataset_name } }
  end

  def move_to_project project_name, dataset, field_code
    dataset.fetch(field_code)&.update! name: [project_name, field_code].cardname
  end
end
