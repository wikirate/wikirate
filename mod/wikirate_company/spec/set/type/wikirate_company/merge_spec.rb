RSpec.describe Card::Set::Type::WikirateCompany::Json do
  let(:company) { Card["Google LLC"] }
  let(:target) { Card["Los Pollos Hermanos"] }

  describe "ok_to_merge?" do
    it "is not permitted for Joe User" do
      expect(company.ok_to_merge?).to be_falsey
    end

    it "is permitted for admins", as_bot: true do
      expect(company.ok_to_merge?).to be_truthy
    end
  end

  def expect_answers_to_move
    expect(company.answers.count).to eq(2)
    expect(target.answers.count).to eq(9)
    yield
    expect(company.answers.count).to eq(1) # there is one conflicting answer
    expect(target.answers.count).to eq(10)
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
    let(:metric) { Card["Jedi+more evil"]}

    it "should move non-conflicting answers from source to target company" do
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

    "woot"
  end
end