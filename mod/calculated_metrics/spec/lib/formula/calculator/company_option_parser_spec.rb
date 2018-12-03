RSpec.describe Formula::Calculator::Input::CompanyOptionParser do

  let(:death_star_id) { Card.fetch_id "Death Star" }
  let(:apple_id) { Card.fetch_id "Apple Inc" }
  let(:samsung_id) { Card.fetch_id "Samsung" }

  it "parses" do
    dc = described_class.new "Related[Jedi+more evil = yes]"
    expect(dc.sql)
      .to eq "SELECT r0.subject_company_id, r0.year, "\
              "GROUP_CONCAT(r0.object_company_id SEPARATOR '##') FROM relations AS r0 "\
              "WHERE (r0.metric_id = 7000) && (r0.value = \"yes\") "\
              "GROUP BY r0.subject_company_id, r0.year"
  end

  it "pas" do
      dc = described_class.new "Related[Jedi+more evil = yes]"
      expect(dc.companies_and_years)
        .to eq "SELECT r.sc, r.year, GROUP_CONCAT(r.oc SEPARATOR '##') FROM relationships "\
               "AS r GROUP BY r.sc, r.year WHERE (r0.metric_id = 7000) && "\
               "(r0.value = \"yes\") GROUP BY r.sc, r.year"
    end
end
