RSpec.describe Card::Set::Abstract::Delist do
  let(:company) { Card["SPECTRE"] }
  let(:project) { Card["Evil Project"]}

  it "deletes company from project when company is deleted", as_bot: true do
    company.delete!
    expect(project.wikirate_company_card.item_names).not_to include("SPECTRE")
  end
end