describe Card::Set::Type::RelationshipAnswer do
  let(:metric) { "Jedi+more evil" }
  context "add new relationship answer" do
    def add_relationship_answer
      Card[metric].create_values true do
        Death_Star "1977" => { "Monster Inc" => "yes" }
      end
    end

    def answer
      Card["Jedi+more evil+Death Star+1977"]
    end

    it "updates company count" do
      expect { add_relationship_answer }.to change(answer, :value).from("2").to("3")
    end
  end

  context "change relationship answer name" do
    def change_relationship_answer_name
      Card["Jedi"]
    end
  end

end
