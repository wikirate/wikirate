
RSpec.describe Card::Set::Type::CompanyGroup do
  def card_subject
    Card["Deadliest"]
  end

  check_html_views_for_errors

  # Both SPECTRE and Monster Inc have Supplied By answers,
  # but only SPECTRE is supplied by Google LLC (the sole member of the Googliest Group)
  it "handles related company group restrictions" do
    supgoog =
      Card.create! name: "Google Supplied",
                   type: :company_group,
                   subfields: {
                     specification: "[[Commons+Supplied by]],latest,,Googliest"
                   }

    expect(supgoog.wikirate_company_card.item_names).to eq(["SPECTRE"])
  end
end
