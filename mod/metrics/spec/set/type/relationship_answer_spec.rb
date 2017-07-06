describe Card::Set::Type::RelationshipAnswer do
  let(:metric) { "Jedi+more evil" }
  context "add new relationship answer" do
    def add_relationship_answer
      Card[metric].create_values true do
        Death_Star "1977" => { "Monster Inc" => "yes" }
      end
    end

    def add_first_relationship_answer
      Card[metric].create_values true do
        Monster_Inc "1977" => { "Slate_Rock_and_Gravel_Company" => "yes" }
      end
    end

    def answer
      Card["Jedi+more evil+Death Star+1977"]
    end

    it "updates company count" do
      expect { add_relationship_answer }
        .to change(answer, :value).from("2").to("3")
    end

    it "first relationship answer increases cached answer count" do
      expect { add_first_relationship_answer }
        .to change(Card.fetch("Monster Inc+metric"), :cached_count).from(3).to(4)

    end

    it "further relationship answers don't increase cached answer count" do
      expect { add_relationship_answer }
        .not_to change(Card.fetch("Death Star+metric"), :cached_count)

    end

    it "check seeding" do
      expect { seed_add }
        .to change(Card.fetch("Los_Pollos_Hermanos+metric"), :cached_count) #.from(3).to(4)
    end

    def seed_add
      Card::Metric.create name: "Jedi+more evil 2",
                          type: :relationship,
                          random_source: true,
                          value_type: "Category",
                          value_options: %w(yes no),
                          inverse_title: "less evil 2" do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "yes" }
        Los_Pollos_Hermanos "1977" => { "Los_Pollos_Hermanos" => "yes", "SPECTRE" => "yes" }
      end
    end
  end

  context "change relationship answer name" do
    def change_relationship_answer_name
      Card["Jedi"]
    end
  end

end
