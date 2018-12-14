# -*- encoding : utf-8 -*-

describe Card::Set::Type::Project do
  def card_subject
    Card["Evil Project"]
  end

  let(:project) { card_subject }

  context "with no year" do
    check_views_for_errors :open_content, :bar, :edit, :wikirate_company_tab,
                           :metric_tab, :post_tab, :subproject_tab

    it "has no year" do
      expect(card_subject.years).to eq(false)
    end

    it "connects metrics and companies" do
      expect_stat :num, metrics: 2, companies: 3
    end

    it "counts all records" do
      expect_stat :num, possible: 6, researched: 2, unknown: 0, not_researched: 4
    end

    it "calculates progress percentages based on records" do
      expect_stat :percent, researched: 33.3, unknown: 0, not_researched: 66.6
    end
  end

  context "with years" do
    let :project do
      card_subject.year_card.update! content: "1999\n2000\n2001"
      card_subject
    end

    it "lists years in order of recency" do
      expect(project.years).to eq(%w[2001 2000 1999])
    end

    it "connects metrics and companies" do
      expect_stat :num, metrics: 2, companies: 3
    end

    it "counts all answers" do
      expect_stat :num, possible: 18, researched: 3, unknown: 0, not_researched: 15
      # note: 2 researched for same record
    end

    it "calculates progress percentages based on answers" do
      expect_stat :percent, researched: 16.6, unknown: 0, not_researched: 83.3
    end
  end

  def expect_stat stat, hash
    hash.each do |field, expected|
      result = project.send "#{stat}_#{field}"
      expect(result).to eq(expected)
    end
  end
end
