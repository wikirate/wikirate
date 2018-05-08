# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Homepage, type: :controller do
  let(:golden_master) do
    ::File.read(File.expand_path("../homepage.html", __FILE__))
  end

  def remove_head html
    html.gsub(/<head>.+<\/head>/m, "").gsub(/data-card-id="\d+"/, "")
        .gsub(/src="[^"]+"/, "").strip
  end

  xspecify "homepage is fine" do
    homepage = Card.fetch(:homepage).format.page CardController.new, nil, nil
    expect(remove_head(homepage).gsub("\r",""))
      .to eq remove_head(golden_master)
  end
end
