RSpec.describe Card::Set::Type::RelationshipAnswer do
  def card_subject
    Card["Commons+Supplied by+Monster_Inc+1977+Los_Pollos_Hermanos"]
  end

  check_html_views_for_errors

  %w[Views Listing Flags].each do |subdir|
    abstract_answer_views =
      Card::Set::Format::AbstractFormat::ViewDefinition.views[
        Card::Set::Abstract::MetricAnswer.const_get(subdir).const_get("HtmlFormat")
      ].keys
    include_context_for abstract_answer_views, "view without errors"
    include_context_for abstract_answer_views, "view with valid html"
  end

  let(:year) { "1977" }
  let(:metric) { "Jedi+more evil" }
  let(:inverse_metric) { "Jedi+less evil" }

  context "when adding first relationship answer" do
    def add_first_relationship_answer
      Card[metric].create_answers true do
        Monster_Inc "1977" => { "Slate_Rock_and_Gravel_Company" => "yes" }
      end
    end

    it "increases cached answer count" do
      Card.fetch("Monster Inc+metric").cached_count
      expect { add_first_relationship_answer }
        .to change(Card.fetch("Monster Inc+metric"), :cached_count).from(6).to(7)
    end

    it "creates inverse answer" do
      add_first_relationship_answer
      inverse_answer_value =
        Card[inverse_metric, "Slate_Rock_and_Gravel_Company", year, :value]
      expect(inverse_answer_value.content).to eq "1"
    end
  end

  context "when adding another relationship answer" do
    def add_relationship_answer
      Card[metric].create_answers true do
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

  # THIS mimics how relationship answers are created via the research page
  context "with 'related_company' subcard" do
    it "handles missing object company" do
      card = Card.create! type_id: Card::RelationshipAnswerID,
                          name: Card::Name[metric, "SPECTRE", "2001", ""],
                          subcards: {
                            "+related_company" => "Death Star",
                            "+value" => "no",
                            "+source" => :star_wars_source.cardname
                          }
      expect(card.name.tag).to eq("Death Star")
      expect(card.fetch(:related_company)).to be_nil
    end
  end

  context "when deleting" do
    it "deletes relationship lookup" do
      Card::Auth.as "joe admin"
      rel = card_subject
      value_card_id = rel.value_card.id
      expect(rel.lookup).to be_present
      expect(value_card_id).to be_present
      rel.delete!
      expect(rel.lookup).to be_nil
      expect(Card[value_card_id]).to be_nil
    end
  end

  # context "when changing relationship answer name" do
  #   def change_relationship_answer_name
  #     Card["Jedi"]
  #   end
  # end
end
