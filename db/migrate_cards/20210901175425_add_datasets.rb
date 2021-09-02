# -*- encoding : utf-8 -*-

class AddDatasets < Cardio::Migration
  def up
    ensure_code_card "Data Set", codename: :dataset
    Card.search type: "Project" do |project|
      project.update! type: "Data Set"
    end
    Card[:subproject].update! codename: :data_subset
  end
end
