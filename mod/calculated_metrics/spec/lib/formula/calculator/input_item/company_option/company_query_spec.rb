RSpec.describe Formula::Calculator::InputItem::Options::CompanyOption::CompanyQuery do
  def sql str
    described_class.new(str).sql
  end

  let(:more_evil_id) { Card.fetch_id "Jedi+more evil" }

  example "simple related condition" do
    expect(sql("Related[Jedi+more evil]"))
      .to eq "SELECT r0.subject_company_id, r0.year, "\
             "GROUP_CONCAT(r0.object_company_id SEPARATOR '##') "\
             "FROM relationships AS r0 "\
             "WHERE ((r0.metric_id = #{more_evil_id} && r0.value = \"yes\")) "\
             "GROUP BY r0.subject_company_id, r0.year"
  end



end
