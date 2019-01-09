RSpec.describe Formula::Calculator::InputItem::Options::CompanyOption::CompanySearch::CompanyRelatedParser do
  def parser expr="Jedi+more evil = yes"
    described_class.new expr, Formula::Calculator::SearchSpace.new
  end
  let(:sc_id_1) { Card.fetch_id "Death Star" }
  let(:sc_id_2) { Card.fetch_id "SPECTRE" }

  let(:oc_id_1) { Card.fetch_id "Los Pollos Hermanos" }
  let(:oc_id_2) { Card.fetch_id "SPECTRE" }
  let(:oc_id_3) { Card.fetch_id "Google LLC" }

  specify "sql" do
    metric_id = Card.fetch_id "Jedi+more evil"
    expect(parser.send(:sql))
      .to eq "SELECT r0.subject_company_id, r0.year, "\
             "GROUP_CONCAT(r0.object_company_id SEPARATOR '##') "\
             "FROM relationships AS r0 "\
             "WHERE ((r0.metric_id = #{metric_id} && r0.value = \"yes\")) "\
             "GROUP BY r0.subject_company_id, r0.year"
  end

  specify "sql for inverse metric" do
    metric_id = Card.fetch_id "Jedi+more evil"
    expect(parser("Jedi+less evil = yes").send(:sql))
      .to eq "SELECT r0.object_company_id, r0.year, "\
             "GROUP_CONCAT(r0.subject_company_id SEPARATOR '##') "\
             "FROM relationships AS r0 "\
             "WHERE ((r0.metric_id = #{metric_id} && r0.value = \"yes\")) "\
             "GROUP BY r0.object_company_id, r0.year"
  end

  specify "sql for &&" do
    metric_id_1 = Card.fetch_id "Jedi+more evil"
    metric_id_2 = Card.fetch_id "Commons+Supplied by"
    expect(parser("Jedi+less evil = yes && Commons+Supplied by = Tier 2 Supplier").send(:sql))
      .to eq "SELECT r0.object_company_id, r0.year, "\
             "GROUP_CONCAT(r0.subject_company_id SEPARATOR '##') "\
             "FROM relationships AS r0 "\
             "LEFT JOIN relationships AS r1 " \
             "ON r0.subject_company_id = r1.object_company_id && "\
             "r0.object_company_id = r1.subject_company_id && r0.year = r1.year "\
             "WHERE ((r0.metric_id = #{metric_id_1} && r0.value = \"yes\") && "\
             "(r1.metric_id = #{metric_id_2} && r1.value = \"Tier 2 Supplier\")) "\
             "GROUP BY r0.object_company_id, r0.year"
  end

  specify "sql for ||" do
    metric_id_1 = Card.fetch_id "Jedi+more evil"
    metric_id_2 = Card.fetch_id "Commons+Supplied by"
    expect(parser("Jedi+less evil = yes || Commons+Supplied by = Tier 2 Supplier").send(:sql))
      .to eq "SELECT r0.object_company_id, r0.year, "\
             "GROUP_CONCAT(r0.subject_company_id SEPARATOR '##') "\
             "FROM relationships AS r0 "\
             "WHERE ((r0.metric_id = #{metric_id_1} && r0.value = \"yes\") || "\
             "(r0.metric_id = #{metric_id_2} && r0.value = \"Tier 2 Supplier\")) "\
             "GROUP BY r0.object_company_id, r0.year"
  end


  describe "#relations" do
    example "simple expression" do
      expect(parser.relations)
        .to contain_exactly [sc_id_1, 1977, contain_exactly(oc_id_1, oc_id_2)],
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

    example "simple expression with inverse relationship" do
      expect(parser("Jedi+less evil").relations)
        .to contain_exactly [oc_id_1, 1977, contain_exactly(sc_id_1, sc_id_2)],
                            [oc_id_2, 1977, [sc_id_1]]
    end

    example "or expression with inverse relationship" do
      p = parser("Jedi+less evil = yes || Commons+Supplied by = Tier 2 Supplier")
      expect(p.relations)
        .to contain_exactly [oc_id_1, 1977, contain_exactly(sc_id_1, sc_id_2)],
                            [oc_id_2, 1977, [sc_id_1]],
                            [sc_id_2, 1977, [oc_id_1]],
                            [sc_id_2, 2000, [oc_id_3]]
    end
  end
end
