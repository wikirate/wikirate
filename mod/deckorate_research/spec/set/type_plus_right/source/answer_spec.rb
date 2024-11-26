RSpec.describe Card::Set::TypePlusRight::Source::Answer do
  it_behaves_like "cached count", %i[star_wars_source answer], 20, 1 do
    let :add_one do
      create_answers "Jedi+Weapons" do
        Samsung "1977" => { value: "hand", source: Card[:star_wars_source] }
      end
    end
    let :delete_one do
      Card["Jedi+cost of planets destroyed+Death Star+1977"].delete
    end
  end

  # TODO: add unpublished card to seed data so we can use the add one / delete one
  # pattern in shared examples.  (could add one by adding answer rather than publishing
  # it...)

  let(:source_answers) { %i[star_wars_source answer] }
  let(:answer) { Card["Jedi+cost of planets destroyed+Death Star+1977"] }

  def current_count
    Card.fetch(source_answers).cached_count
  end

  def unpublish!
    answer.unpublished_card.update! content: "1"
  end

  it "lowers count if answer is unpublished" do
    original_count = current_count
    unpublish!
    # Card::Count.refresh_flagged
    expect(current_count).to eq(original_count - 1)
  end
end
