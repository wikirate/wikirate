describe Card::Set::Type::WikirateCompany do
  it "shows the link for view \"missing\"" do
    html = render_card :missing, type_id: Card::WikirateCompanyID, name: "non-existing-card"
    expect(html).to eq(render_card(:link, type_id: Card::WikirateCompanyID, name: "non-existing-card"))
  end
end
