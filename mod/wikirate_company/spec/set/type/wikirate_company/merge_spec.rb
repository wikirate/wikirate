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
    expect(company.all_answers.count).to eq(2)
    expect(target.all_answers.count).to eq(9)
    yield
    expect(company.all_answers.count).to eq(1) # there is one conflicting answer
    expect(target.all_answers.count).to eq(10)
  end

  describe "#move_all_answers_to" do
    it "should move non-conflicting answers from source to target company" do
      expect_answers_to_move do
        company.move_all_answers_to target.name
      end
    end

    it "should work when triggered within act", as_bot: true do
      Card::Env.params[:target_company] = target.name

      expect_answers_to_move do
        company.update! trigger: :merge_companies
      end
    end
  end

  describe "#move_source_listings_to" do

    "woot"
  end
end