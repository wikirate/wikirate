RSpec.describe Card::Set::Self::Jurisdiction do
  let(:json_format) { Card[:jurisdiction].format(:json) }

  describe "#group_by_country" do
    example "full search" do
      expect(json_format.select2_option_list).to include(
        { text: "United States",
          children: include(
            { id: "Illinois (United States)".card_id, text: "Illinois" },
            id: "Indiana (United States)".card_id, text: "Indiana"
          ) },
        { id: "Canada".card_id, text: "Canada" },
        { text: "Canada",
          children: include(id: "Alberta (Canada)".card_id, text: "Alberta") },
        { id: "Holy See (Vatican City State)".card_id,
          text: "Holy See (Vatican City State)" }
      )
    end

    example "name search" do
      Card::Env.params[:q] = "Cali"
      expect(json_format.select2_option_list)
        .to contain_exactly id: "California (United States)".card_id,
                            text: "California (United States)"
    end
  end
end
