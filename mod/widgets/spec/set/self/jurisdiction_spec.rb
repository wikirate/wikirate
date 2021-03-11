RSpec.describe Card::Set::Self::Jurisdiction do
  let(:json_format) { Card[:jurisdiction].format(:json) }

  describe "#group_by_country" do
    example "full search" do
      expect(json_format.select2_option_list).to include(
        { text: "United States",
          children: include(
            { id: Card.fetch_id("Illinois (United States)"), text: "Illinois" },
            id: Card.fetch_id("Indiana (United States)"), text: "Indiana"
          ) },
        { id: Card.fetch_id("Canada"), text: "Canada" },
        { text: "Canada",
          children: include(id: Card.fetch_id("Alberta (Canada)"), text: "Alberta") },
        { id: Card.fetch_id("Holy See (Vatican City State)"),
          text: "Holy See (Vatican City State)" }
      )
    end

    example "name search" do
      Card::Env.params[:q] = "Cali"
      expect(json_format.select2_option_list)
        .to contain_exactly id: Card.fetch_id("California (United States)"),
                            text: "California (United States)"
    end
  end
end
