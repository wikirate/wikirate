# frozen_string_literal: true

RSpec.describe Formula::Calculator::InputItem::Options::CompanyOption::CompanySearch::CompanyQuery do
  let(:more_evil_id) { Card.fetch_id "Jedi+more evil" }
  let(:less_evil_id) { Card.fetch_id "Jedi+less evil" }
  let(:supplied_by_id) { Card.fetch_id "Commons+Supplied by" }
  let(:deadliness_id) { Card.fetch_id "Jedi+deadliness" }

  describe "#sql", output_length: 5000 do
    def sql str
      described_class.new(str, nil).sql.tr("\n", " ").squeeze(" ").strip
    end

    def eq_sql sql
      eq sql.strip_heredoc.tr("\n", " ").squeeze(" ").strip
    end

    example "exist condition" do
      expect(sql("Related[Jedi+more evil]"))
        .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, r0.object_company_id
                   FROM relationships AS r0
                   WHERE ((r0.metric_id = #{more_evil_id}))
      SQL
    end

    example "operator condition" do
      expect(sql("Related[Jedi+more evil = yes]"))
        .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, r0.object_company_id
                   FROM relationships AS r0
                   WHERE ((r0.metric_id = #{more_evil_id} && r0.value = "yes"))
      SQL
    end

    example "and condition" do
      expect(sql("Related[Jedi+more evil = yes && Commons+supplied_by=Tier 1]"))
        .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, r0.object_company_id
                   FROM relationships AS r0
                   LEFT JOIN relationships AS r1 ON
                   r0.subject_company_id = r1.subject_company_id &&
                   r0.object_company_id = r1.object_company_id && r0.year = r1.year
                   WHERE ((r0.metric_id = #{more_evil_id} && r0.value = "yes") AND
                   (r1.metric_id = #{supplied_by_id} && r1.value = "Tier 1"))
      SQL
    end

    example "or condition" do
      expect(sql("Related[Jedi+more evil = yes || Commons+supplied_by=Tier 1]"))
        .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, r0.object_company_id
                   FROM relationships AS r0
                   WHERE ((r0.metric_id = #{more_evil_id} && r0.value = "yes") OR
                   (r0.metric_id = #{supplied_by_id} && r0.value = "Tier 1"))
      SQL
    end

    example "with answer condition" do
      expect(sql("Related[Jedi+more evil = yes] && Jedi+deadliness > 10"))
        .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, r0.object_company_id
                   FROM relationships AS r0
                   LEFT JOIN answers AS a0 ON
                   r0.object_company_id = a0.company_id && r0.year = a0.year
                   WHERE ((r0.metric_id = #{more_evil_id} && r0.value = "yes")) &&
                   ((a0.metric_id = #{deadliness_id} && a0.numeric_value > 10))
      SQL
    end

    example "inverse metric" do
      expect(sql("Related[Jedi+less evil]"))
        .to eq_sql <<-SQL
                   SELECT r0.object_company_id, r0.year, r0.subject_company_id
                   FROM relationships AS r0
                   WHERE ((r0.inverse_metric_id = #{less_evil_id}))
      SQL
    end

    example "inverse metric with or condition" do
      expect(sql("Related[Jedi+less evil || Commons+supplied_by=Tier 1]"))
        .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, r0.object_company_id
                   FROM (
                     SELECT subject_company_id, object_company_id,
                            metric_id, inverse_metric_id, year, value
                     FROM relationships
                     WHERE metric_id = #{supplied_by_id}
                     UNION
                     SELECT object_company_id as subject_company_id,
                            subject_company_id as object_company_id,
                            metric_id, inverse_metric_id, year, value
                     FROM relationships
                     WHERE inverse_metric_id = #{less_evil_id}
                   ) AS r0
                   WHERE ((r0.inverse_metric_id = #{less_evil_id})
                   OR (r0.metric_id = #{supplied_by_id} && r0.value = "Tier 1"))
      SQL
    end

    example "inverse metric and metric" do
      expect(sql("Related[Jedi+less evil && Commons+supplied_by=Tier 1]"))
        .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, r0.object_company_id
                   FROM
                   ( SELECT object_company_id as subject_company_id,
                            subject_company_id as object_company_id,
                            metric_id, inverse_metric_id, year, value
                     FROM relationships
                   ) AS r0
                   LEFT JOIN relationships AS r1
                   ON r0.subject_company_id = r1.subject_company_id &&
                      r0.object_company_id = r1.object_company_id &&
                      r0.year = r1.year
                   WHERE ((r0.inverse_metric_id = #{less_evil_id})
                   AND (r1.metric_id = #{supplied_by_id} && r1.value = "Tier 1"))
      SQL
    end

    example "metric and inverse metric" do
      expect(sql("Related[Commons+supplied_by=Tier 1 && Jedi+less evil]"))
        .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, r0.object_company_id
                   FROM relationships AS r0
                   LEFT JOIN
                   (
                     SELECT object_company_id as subject_company_id,
                            subject_company_id as object_company_id,
                            metric_id, inverse_metric_id, year, value
                     FROM relationships
                     WHERE inverse_metric_id = #{less_evil_id}
                   ) AS r1
                   ON r0.subject_company_id = r1.subject_company_id &&
                      r0.object_company_id = r1.object_company_id &&
                      r0.year = r1.year
                   WHERE ((r0.metric_id = #{supplied_by_id} && r0.value = "Tier 1")
                   AND (r1.inverse_metric_id = #{less_evil_id}))
      SQL
    end

    it "doesn't allow '&&' and '||'" do
      formula = "Related[Jedi+less evil || Commons+supplied_by=Tier 1 && Jedi+more evil]"
      expect { sql(formula) }
        .to raise_error /is not supported/
    end

    it "doesn't allow more than one related" do
      expect { sql("Related[Jedi+less evil] && Related[Commons+supplied_by=Tier 1]") }
        .to raise_error /only one 'Related'/
    end

    it "doesn't allow dangerous characters" do
      expect { sql("Related[Jedi+less evil > 5; drop table]") }
        .to raise_error /value is not allowed to contain/
    end
  end

  describe "#relations" do
    let(:sc_id_1) { Card.fetch_id "Death Star" }
    let(:sc_id_2) { Card.fetch_id "SPECTRE" }

    let(:oc_id_1) { Card.fetch_id "Los Pollos Hermanos" }
    let(:oc_id_2) { Card.fetch_id "SPECTRE" }
    let(:oc_id_3) { Card.fetch_id "Google LLC" }

    def relations str
      rel = described_class.new(str, Formula::Calculator::SearchSpace.new).relations
      rel.keys.each_with_object([]) { |a, res| rel[a].each { |c, d| res << [a, c, d] } }
    end

    example "exist condition" do
      expect(relations("Related[Jedi+more evil]"))
        .to contain_exactly [sc_id_1, 1977, contain_exactly(oc_id_1, oc_id_2)],
                            [sc_id_2, 1977, [oc_id_1]]
    end

    example "and expression" do
      formula = "Related[Jedi+more evil = yes && Commons+Supplied by = Tier 1 Supplier]"
      expect(relations(formula))
        .to contain_exactly [sc_id_2, 1977, [oc_id_1]]
    end

    example "or expression" do
      rel = relations("Related[Jedi+more evil = yes || "\
                      "Commons+Supplied by = Tier 2 Supplier]")
      expect(rel)
        .to contain_exactly [sc_id_1, 1977, contain_exactly(oc_id_1, oc_id_2)],
                            [sc_id_2, 1977, [oc_id_1]],
                            [sc_id_2, 2000, [oc_id_3]]
    end

    example "inverse relationship" do
      expect(relations("Related[Jedi+less evil]"))
        .to contain_exactly [oc_id_1, 1977, contain_exactly(sc_id_1, sc_id_2)],
                            [oc_id_2, 1977, [sc_id_1]]
    end

    example "inverse metric or metric" do
      formula = "Related[Jedi+less evil = yes || Commons+Supplied by = Tier 2 Supplier]"
      expect(relations(formula))
        .to contain_exactly [oc_id_1, 1977, contain_exactly(sc_id_1, sc_id_2)],
                            [oc_id_2, 1977, [sc_id_1]],
                            [sc_id_2, 2000, [oc_id_3]]
    end

    example "inverse metric and inverse metric" do
      formula = "Related[Commons+Supplier of = Tier 1 Supplier && Jedi+less evil = yes]"
      expect(relations(formula))
        .to contain_exactly [oc_id_1, 1977, [sc_id_2]]
    end

    example "relationship and answer metric" do
      rel = relations("Related[Jedis+more evil = yes] && Jedi+deadliness > 40")
      expect(rel)
        .to contain_exactly [sc_id_1, 1977, [oc_id_2]]
    end
  end
end
