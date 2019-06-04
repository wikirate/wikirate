class SharedData
  module Projects
    def add_projects
      create_project "Evil Project",
                     metric: ["Jedi+disturbances in the Force",
                              "Joe User+researched number 2"],
                     wikirate_company: ["Death Star", "SPECTRE", "Los Pollos Hermanos"],
                     wikirate_topic: "Force",
                     wikirate_status: "Active",
                     organizer: "Jedi"

      create_project "Son of Evil Project",
                     parent: "Evil Project", metric: [], wikirate_company: []

      create_project "Empty Project", metric: [], wikirate_company: []
    end

    def create_project name, subfields
      hash = { type: :project, subfields: {} }
      subfields.each do |codename, values|
        hash[:subfields][codename] = { type: :pointer, content: values }
      end
      create name, hash
    end
  end
end
