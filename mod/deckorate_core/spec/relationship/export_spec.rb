RSpec.describe Relationship::Export do
  let :relationship_answer do
    Card["Jedi+more evil+Death Star+1977+SPECTRE"]
  end

  # relationship_id, answer_link, answer_id, metric_name,
  #   subject_company_name, object_company_name, year, value
  it "renders csv line" do
    expect(relationship_answer.lookup.csv_line)
      .to match(/\d+,Jedi\+more evil,Death Star,SPECTRE,1977,yes/)
  end
end
