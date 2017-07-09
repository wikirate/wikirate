describe Card::Set::Type::RelationshipAnswer do
  let(:metric) { "Jedi+more evil" }
  let(:inverse_metric) { "Jedi+less evil" }
  let(:year) { "1977" }

  context "add first relationship answer" do
    def add_first_relationship_answer
      Card[metric].create_values true do
        Monster_Inc "1977" => { "Slate_Rock_and_Gravel_Company" => "yes" }
      end
    end

    it "increases cached answer count" do
      expect { add_first_relationship_answer }
        .to change(Card.fetch("Monster Inc+metric"), :cached_count).from(4).to(5)
    end

    it "creates inverse answer" do
      add_first_relationship_answer
      inverse_answer_value =
        Card[inverse_metric, "Slate_Rock_and_Gravel_Company", year, :value]
      expect(inverse_answer_value.content).to eq "1"
    end
  end

  context "add another relationship answer" do
    def add_relationship_answer
      Card[metric].create_values true do
        Death_Star "1977" => { "Monster Inc" => "yes" }
      end
    end

    def answer
      Card[metric, "Death Star", year]
    end

    def inverse_answer
      Card[inverse_metric, "Monster Inc", year]
    end

    it "updates company count" do
      expect { add_relationship_answer }
        .to change(answer, :value).from("2").to("3")
    end

    it "creates inverse company count" do
      add_relationship_answer
      expect(inverse_answer.value).to eq "1"
    end

    it "doesn't increase cached answer count" do
      expect { add_relationship_answer }
        .not_to change(Card.fetch("Death Star+metric"), :cached_count)
    end
  end

  context "change relationship answer name" do
    def change_relationship_answer_name
      Card["Jedi"]
    end
  end
end
