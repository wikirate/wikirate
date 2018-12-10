RSpec.describe Formula::Calculator::InputItem::CompanyOption::CompanyRelated::CompanyRelatedParser do
  def parser expr="Jedi+more evil = yes"
    described_class.new expr, Formula::Calculator::SearchSpace.new
  end
  let(:sc_id_1) { Card.fetch_id "Death Star" }
  let(:sc_id_2) { Card.fetch_id "SPECTRE" }

  let(:oc_id_1) { Card.fetch_id "Los Pollos Hermanos" }
  let(:oc_id_2) { Card.fetch_id "SPECTRE" }
  let(:oc_id_3) { Card.fetch_id "Google LLC" }

  specify "sql" do
    expect(parser.send(:sql))
      .to eq "SELECT r0.subject_company_id, r0.year, "\
             "GROUP_CONCAT(r0.object_company_id SEPARATOR '##') "\
             "FROM relationships AS r0 "\
             "WHERE ((r0.metric_id = 7000 && r0.value = \"yes\")) "\
             "GROUP BY r0.subject_company_id, r0.year"
  end

  describe "#relations" do
    example "simple expression" do
      expect(parser.relations)
        .to contain_exactly  [sc_id_1, 1977, contain_exactly(oc_id_1, oc_id_2)],
                            [sc_id_2, 1977, [oc_id_1]]
    end

    example "and expression" do
      p = parser("Jedi+more evil = yes && Commons+Supplied by = Tier 1 Supplier")
      expect(p.relations)
        .to contain_exactly [sc_id_2, 1977, [oc_id_1]]
    end

    example "or expression" do
      p = parser("Jedi+more evil = yes || Commons+Supplied by = Tier 2 Supplier")
      expect(p.relations)
        .to contain_exactly [sc_id_1, 1977, contain_exactly(oc_id_1, oc_id_2)],
                            [sc_id_2, 1977, [oc_id_1]],
                            [sc_id_2, 2000, [oc_id_3]]
    end
  end
end
