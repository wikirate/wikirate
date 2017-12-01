# -*- encoding : utf-8 -*-

describe Card::Set::Type::Project do
  context "with no year" do
    let(:project) { Card["Evil Project"] }

    it "has no year" do
      expect(project.years).to eq(false)
    end

    it "connects metrics and companies" do
      expect(project.num_metrics).to eq(2)
      expect(project.num_companies).to eq(3)
    end

    it "counts all answers" do
      expect(project.num_researched).to eq(2)
      expect(project.num_unknown).to eq(0)
      expect(project.num_not_researched).to eq(4)
    end

    it "calculates progress percentages based on records" do
      expect(project.num_possible).to eq(6)
      expect(project.percent_researched).to eq(33.3)
      expect(project.percent_unknown).to eq(0)
      expect(project.percent_not_researched).to eq(66.6)
    end
  end

  context "with years" do
    let :project do
      project = Card["Evil Project"]
      project.year_card.update_attributes! content: "1999\n2000\n2001"
      project
    end

    it "lists years in order of recency" do
      expect(project.years).to eq(%w[2001 2000 1999])
    end

    it "connects metrics and companies" do
      expect(project.num_metrics).to eq(2)
      expect(project.num_companies).to eq(3)
    end

    it "counts all answers" do
      expect(project.num_researched).to eq(3) # note: 2 for same record
      expect(project.num_unknown).to eq(0)
      expect(project.num_not_researched).to eq(15)
    end

    it "calculates progress percentages based on answers" do
      expect(project.num_possible).to eq(18)
      expect(project.percent_researched).to eq(16.6)
      expect(project.percent_unknown).to eq(0)
      expect(project.percent_not_researched).to eq(83.3)
    end
  end
end
