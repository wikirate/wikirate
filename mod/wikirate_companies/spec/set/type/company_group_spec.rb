
RSpec.describe Card::Set::Type::CompanyGroup do
  def card_subject
    Card["Deadliest"]
  end

  check_views_for_errors

  # Both SPECTRE and Monster Inc have Supplied By answers,
  # but only SPECTRE is supplied by Google LLC (the sole member of the Googliest Group)
  it "handles related company group restrictions" do
    supgoog =
      Card.create! name: "Google Supplied",
                   type: :company_group,
                   fields: {
                     specification: [
                       { metric_id: "Commons+Supplied by",
                         year: "latest",
                         related_company_group: "Googliest" }
                     ]
                   }

    expect(supgoog.company_card.item_names).to eq(["SPECTRE"])
  end
end
