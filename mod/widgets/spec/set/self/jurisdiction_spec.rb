RSpec.describe Card::Set::Self::Jurisdiction do
  let(:json_format) { Card[:jurisdiction].format(:json) }

  specify "#group_by_country" do
    expect(json_format.group_by_country).to include(
      { text: "United States",
        children: include(
          { id: :oc_us_il, text: "Illinois" },
          { id: :oc_us_in, text: "Indiana" }
        )},
      { id: :oc_ca, text: "Canada" },
      { text: "Canada", children: include({ id: :oc_ca_ab, text: "Alberta" }) },
      { id: :oc_va, text: "Holy See (Vatican City State)" }
    )
  end
end
