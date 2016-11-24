describe Card::Set::Type::Metric::Table do
  let(:metric) { "Jedi+disturbances in the Force" }
  let(:metric_value) { "Jedi+disturbances_in_the_Force+Death_Star+1977" }
  subject { Card[metric].format(:html).company_table }

  it "has a bootstrap table" do
    log_html subject
    is_expected.to have_tag "table" do
      with_tag :tr, with: { data: { details_url: "#{metric_value}?view=company_details_sidebar" } }
    end
  end

end
