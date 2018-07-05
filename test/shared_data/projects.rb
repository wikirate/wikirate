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

      create_project "Empty Project", metric: [], wikirate_company: []
    end

    def create_project name, subfields
      hash = { type: :project, subfields: {} }
      subfields.each do |codename, values|
        puts "hash[:subfields][#{codename}] = #{project_subfield values}"
        hash[:subfields][codename] = project_subfield values
      end
      create name, hash
    end

    def project_subfield values
      {
        type: :pointer,
        content: (Array.wrap(values).map { |v| "[[#{v}]]" }.join("\n"))
      }
    end
  end
end