class SharedData
  module ProfileSections
    def add_profile_sections
      metric_section
      answer_section
      topic_section
      project_section
      research_group_section
      company_section
    end

    def answer_field year, field
      "Joe User+big single+Sony Corporation+#{year}+#{field}"
    end

    def answer_section
      with_user "Joe User" do
        update_card answer_field(2010, :value),
                    content: "4"
        update_card answer_field(2008, :value),
                    content: "5"

        ensure_card answer_field(2007, :discussion),
                    content: "comment"
        ensure_card answer_field(2005, :checked_by),
                    content: "[[Joe User]]"
        ensure_card answer_field(2003, :checked_by),
                    content: "[[request]]"
        ensure_card answer_field(2003, :check_requested_by),
                    content: "[[Joe User]]"
      end

      with_user "Joe Admin" do
        update_card answer_field(2009, :value),
                    content: "5"
        update_card answer_field(2008, :value),
                    content: "6"

        ensure_card answer_field(2006, :discussion),
                    content: "comment"
        ensure_card answer_field(2004, :checked_by),
                    content: "[[Joe Admin]]"
      end
    end

    def metric_section
      # reuse existing metrics
      with_joe_user do
        create_card "Joe User+small single+about", {}
        update_card "Joe User+small single+about", content: "changed"

        create_card ["Jedi+Victims by Employees", :discussion],
                    content: "comment"
      end
    end

    def topic_section
      add_section :wikirate_topic, true
    end

    def project_section
      add_section :project
      add_project_conversation
      with_user "Joe Admin" do
        create_card "organized project", type: :project
      end
      with_user "Joe User" do
        create_card "submitted project", type: :project
        create_card ["organized project", :organizer],
                    content: "[[Joe User]]"
      end
    end

    def research_group_section
      add_section :research_group
    end

    def company_section
      add_section :wikirate_company
    end

    def add_section type_code, bookmark=false
      type = Card.fetch_name(type_code).downcase
      with_user "Joe Admin" do
        create_card "updated #{type}", type: type_code
        create_card "discussed #{type}", type: type_code
        create_card "bookmarked #{type}", type: type_code
      end
      with_user "Joe User" do
        create_card "created #{type}", type: type_code
        update_card "updated #{type}", content: "updated"
        create_card ["discussed #{type}", :discussion], content: "comment"
        bookmark "bookmarked #{type}" if bookmark
      end
    end

    def add_project_conversation
      with_user "Joe Admin" do
        create_card "conversation project", type: :project
      end
      with_joe_user do
        Card.create! name: "discuss conversation project 2",
                     type: :conversation,
                     subfields: {
                       project: { content: "[[conversation project]]" },
                       discussion: { content: "comment" }
                     }
      end
    end
  end
end
