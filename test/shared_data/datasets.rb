class SharedData
  module Datasets
    def add_datasets
      create_with_pointers "Evil Dataset", :dataset,
                           metric: ["Jedi+disturbances in the Force",
                                    "Joe User+researched number 2"],
                           wikirate_company: ["Death Star",
                                              "SPECTRE",
                                              "Los Pollos Hermanos"],
                           wikirate_topic: "Force"

      create_with_pointers "Son of Evil Dataset", :dataset,
                           parent: "Evil Dataset",
                           metric: [],
                           wikirate_company: []

      create_with_pointers "Empty Dataset", :dataset,
                           metric: [],
                           wikirate_company: []
    end

    def add_projects
      create_with_pointers "Evil Project", :project,
                           wikirate_status: "Active",
                           organizer: "Jedi",
                           dataset: "Evil Dataset"

      create_with_pointers "Empty Project", :project,
                           dataset: "Empty Dataset"
    end

    def create_with_pointers name, type, subfields
      subfield_hash = subfields.each_with_object({}) do |(codename, values), hash|
        hash[codename] = { type: :pointer, content: values }
      end
      create name, type: type, subfields: subfield_hash
    end
  end
end
