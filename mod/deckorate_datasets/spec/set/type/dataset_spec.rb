# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Dataset do
  def card_subject
    Card["Evil Dataset"]
  end

  let(:dataset) { card_subject }

  check_views_for_errors
  check_views_for_errors format: :csv, views: %i[titled import_template]
  check_views_for_errors format: :json, views: %i[molecule]

  context "with no year" do
    it "has no year" do
      expect(card_subject.years).to eq([])
    end

    it "connects metrics and companies" do
      expect_stat :num, metrics: 2, companies: 3
    end

    it "counts all records" do
      expect_stat :num, possible: 6, researched: 2, unknown: 0, not_researched: 4
    end

    it "calculates progress percentages based on answers" do
      expect_stat :percent, researched: 33.3, unknown: 0, not_researched: 66.6
    end
  end

  context "with years" do
    let :dataset do
      card_subject.tap do |dataset|
        dataset.year_card.update! content: "1999\n2000\n2001"
      end
    end

    it "lists years in order of recency" do
      expect(dataset.years).to eq(%w[2001 2000 1999])
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
      result = dataset.send "#{stat}_#{field}"
      expect(result).to eq(expected)
    end
  end
end
