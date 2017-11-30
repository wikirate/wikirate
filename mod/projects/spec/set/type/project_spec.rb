# -*- encoding : utf-8 -*-

describe Card::Set::Type::Project do
  context "with no year" do
    subject { Card["Evil Project"] }

    it "has no year" do
      expect(subject.years).to eq(false)
    end

    it "connects metrics and companies" do
      expect(subject.num_metrics).to eq(2)
      expect(subject.num_companies).to eq(3)
    end

    it "counts all answers" do
      expect(subject.num_researched).to eq(2)
      expect(subject.num_unknown).to eq(0)
      expect(subject.num_not_researched).to eq(4)
    end

    it "calculates progress percentages based on records" do
      expect(subject.num_possible).to eq(6)
      expect(subject.percent_researched).to eq(33.3)
      expect(subject.percent_unknown).to eq(0)
      expect(subject.percent_not_researched).to eq(66.6)
    end
  end

  context "with years" do
    subject do
      project = Card["Evil Project"]
      project.year_card.update_attributes! content: "1999\n2000\n2001"
      project
    end

    it "lists years in order of recency" do
      expect(subject.years).to eq(["2001", "2000", "1999"])
    end

    it "connects metrics and companies" do
      expect(subject.num_metrics).to eq(2)
      expect(subject.num_companies).to eq(3)
    end

    it "counts all answers" do
      expect(subject.num_researched).to eq(3) # note: 2 for same record
      expect(subject.num_unknown).to eq(0)
      expect(subject.num_not_researched).to eq(15)
    end

    it "calculates progress percentages based on answers" do
      expect(subject.num_possible).to eq(18)
      expect(subject.percent_researched).to eq(16.6)
      expect(subject.percent_unknown).to eq(0)
      expect(subject.percent_not_researched).to eq(83.3)
    end
  end
end
