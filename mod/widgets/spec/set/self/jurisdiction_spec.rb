RSpec.describe Card::Set::Self::Jurisdiction do
  let(:json_format) { Card[:jurisdiction].format(:json) }

  describe "#group_by_country" do
    example "full search" do
      expect(json_format.select2_option_list).to include(
        { text: "United States",
          children: include(
            { id: :oc_us_il, text: "Illinois" },
            id: :oc_us_in, text: "Indiana"
          ) },
        { id: :oc_ca, text: "Canada" },
        { text: "Canada", children: include(id: :oc_ca_ab, text: "Alberta") },
        { id: :oc_va, text: "Holy See (Vatican City State)" }
      )
    end

    example "name search" do
      Card::Env.params[:q] = "Cali"
      expect(json_format.select2_option_list)
        .to contain_exactly id: :oc_us_ca, text: "California (United States)"
    end
  end
end
