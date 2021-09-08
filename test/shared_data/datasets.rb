class SharedData
  module Datasets
    def add_datasets
      create_dataset "Evil Dataset",
                     metric: ["Jedi+disturbances in the Force",
                              "Joe User+researched number 2"],
                     wikirate_company: ["Death Star", "SPECTRE", "Los Pollos Hermanos"],
                     wikirate_topic: "Force",
                     wikirate_status: "Active",
                     organizer: "Jedi"

      create_dataset "Son of Evil Dataset",
                     parent: "Evil Dataset", metric: [], wikirate_company: []

      create_dataset "Empty Dataset", metric: [], wikirate_company: []
    end

    def create_dataset name, subfields
      hash = { type: :dataset, subfields: {} }
      subfields.each do |codename, values|
        hash[:subfields][codename] = { type: :pointer, content: values }
      end
      create name, hash
    end

    def add_project
      create "Evil Project",
             type: :project,
             subfields: { dataset: { content: "Evil Dataset", type: :pointer } }
    end
  end
end
