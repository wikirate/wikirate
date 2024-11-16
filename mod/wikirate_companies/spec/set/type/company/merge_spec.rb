RSpec.describe Card::Set::Type::Company::Merge do
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

  describe "#move_records_to" do
    def expect_records_to_move target_num
      expect_company_and_target_records 5, 10
      yield
      expect_company_and_target_records 1, target_num
      # Note: move_records_to alone does not move the hq field, so the hq record and
      # the records that depend on it don't move
    end

    def expect_company_and_target_records company_count, target_count
      expect(company.records.count).to eq(company_count)
      expect(target.records.count).to eq(target_count)
    end

    it "moves non-conflicting records from source to target company" do
      expect_records_to_move 11 do
        company.move_records_to target.name
      end
    end

    it "works when triggered within act", as_bot: true do
      Card::Env.params[:target_company] = target.name

      expect_records_to_move 14 do
        company.update! trigger_in_action: :merge_companies
      end
    end
  end

  describe "#move_relationships_to" do
    let(:company) { Card["SPECTRE"] }
    let(:target) { Card["Monster Inc"] }
    let(:metric) { Card["Jedi+more evil"] }

    # currently performed as bot because requires permission to delete
    # simple records where the count is now 0.
    it "moves non-conflicting records to target company", as_bot: true do
      old_record = [metric.name, company.name, "1977"]
      new_record = [metric.name, target.name, "1977"]
      new_relationship = [metric.name, target.name, "1977", "Los_Pollos_Hermanos"]
      expect(Card[*old_record].value).to eq("1")
      expect(Card[*new_record]).to eq(nil)

      with_delayed_jobs do
        company.move_relationships_to target.name
      end

      expect(Card[*new_relationship].value).to eq("yes")
      expect(Card[*new_record].value).to eq("1")
      expect(Card[*old_record]).to eq(nil)
    end
  end

  describe "#move_field_cards_to" do
    it "moves identifiers over" do
      company.sec_cik_card.update! content: "bogusCIK"
      company.move_field_cards_to target.name
      expect(target.sec_cik).to eq("bogusCIK")
    end
  end

  xdescribe "#move_source_listings_to" do
    "TODO"
  end
end
