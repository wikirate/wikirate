describe Card::Set::Type::Metric::Table do
  let(:metric) { "Jedi+disturbances_in_the_Force" }
  let(:metric_value) { "Jedi+disturbances_in_the_Force+Death_Star+2001" }

  describe "#company_table" do
    subject { Card[metric].format(:html).company_table }

    it "has a bootstrap table" do
      is_expected.to have_tag "table" do
        with_tag :tr, with: { "data-details-url" =>
                              "/#{metric_value}?view=company_details_sidebar" }
      end
    end
  end
end
