RSpec.describe Card::Set::Type::WikirateCompany::Merge do
  let(:company) { Card["Google LLC"] }
  let(:target) { Card["Los Pollos Hermanos"] }

  describe "ok_to_merge?" do
    it "is not permitted for Joe User" do
      expect(company).not_to be_ok_to_merge
    end

    it "is permitted for admins", as_bot: true do
      expect(company).to be_ok_to_merge
    end
  end

  def expect_answers_to_move
    expect(company.answers.count).to eq(5)
    expect(target.answers.count).to eq(10)
    yield
    expect(company.answers.count).to eq(1) # there is one conflicting answer
    expect(target.answers.count).to eq(11)
    # Note: we do not move over hq field, so the hq answer and the answers that depend on
    # it don't move
  end

  describe "#move_answers_to" do
    it "should move non-conflicting answers from source to target company" do
      expect_answers_to_move do
        company.move_answers_to target.name
      end
    end

    it "should work when triggered within act", as_bot: true do
      Card::Env.params[:target_company] = target.name

      expect_answers_to_move do
        company.update! trigger: :merge_companies
      end
    end
  end

  describe "#move_relationships_to" do
    let(:company) { Card["SPECTRE"] }
    let(:target) { Card["Monster Inc"] }
    let(:metric) { Card["Jedi+more evil"] }

    # currently performed as bot because requires permission to delete
    # simple answers where the count is now 0.
    it "moves non-conflicting answers to target company", as_bot: true do
      old_answer = [metric.name, company.name, "1977"]
      new_answer = [metric.name, target.name, "1977"]
      new_relationship = [metric.name, target.name, "1977", "Los_Pollos_Hermanos"]
      expect(Card[*old_answer].value).to eq("1")
      expect(Card[*new_answer]).to eq(nil)

      company.move_relationships_to target.name

      expect(Card[*new_relationship].value).to eq("yes")
      expect(Card[*new_answer].value).to eq("1")
      expect(Card[*old_answer]).to eq(nil)
    end
  end

  describe "#move_source_listings_to" do
    "TODO"
  end
end
