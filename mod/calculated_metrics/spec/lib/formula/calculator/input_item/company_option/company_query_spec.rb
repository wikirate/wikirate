RSpec.describe Formula::Calculator::InputItem::Options::CompanyOption::CompanySearch::CompanyQuery do
  def sql str
    described_class.new(str, nil).sql.gsub("\n", " ").squeeze(" ").strip
  end

  def eq_sql sql
    eq sql.strip_heredoc.gsub("\n", " ").squeeze(" ").strip
  end

  let(:more_evil_id) { Card.fetch_id "Jedi+more evil" }
  let(:less_evil_id) { Card.fetch_id "Jedi+less evil" }
  let(:supplied_by_id) { Card.fetch_id "Commons+Supplied by" }
  let(:deadliness_id) { Card.fetch_id "Jedi+deadliness" }

  example "exist condition" do
    expect(sql("Related[Jedi+more evil]"))
      .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year,
                   GROUP_CONCAT(r0.object_company_id SEPARATOR '##')
                   FROM relationships AS r0
                   WHERE ((r0.metric_id = #{more_evil_id}))
                   GROUP BY r0.subject_company_id, r0.year
                 SQL
  end

  example "operator condition" do
    expect(sql("Related[Jedi+more evil = yes]"))
      .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year,
                   GROUP_CONCAT(r0.object_company_id SEPARATOR '##')
                   FROM relationships AS r0
                   WHERE ((r0.metric_id = #{more_evil_id} && r0.value = "yes"))
                   GROUP BY r0.subject_company_id, r0.year
                 SQL
  end

  example "and condition" do
    RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 5000
    expect(sql("Related[Jedi+more evil = yes && Commons+supplied_by=Tier 1]"))
      .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year,
                   GROUP_CONCAT(r0.object_company_id SEPARATOR '##')
                   FROM relationships AS r0
                   LEFT JOIN relationships AS r1 ON
                   r0.subject_company_id = r1.subject_company_id &&
                   r0.object_company_id = r1.object_company_id && r0.year = r1.year
                   WHERE ((r0.metric_id = #{more_evil_id} && r0.value = "yes") AND
                   (r1.metric_id = #{supplied_by_id} && r1.value = "Tier 1"))
                   GROUP BY r0.subject_company_id, r0.year
                 SQL
  end

  example "or condition" do
    RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 5000
    expect(sql("Related[Jedi+more evil = yes || Commons+supplied_by=Tier 1]"))
      .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year,
                   GROUP_CONCAT(r0.object_company_id SEPARATOR '##')
                   FROM relationships AS r0
                   WHERE ((r0.metric_id = #{more_evil_id} && r0.value = "yes") OR
                   (r0.metric_id = #{supplied_by_id} && r0.value = "Tier 1"))
                   GROUP BY r0.subject_company_id, r0.year
                 SQL
  end

  example "with answer condition" do
    RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 5000
    expect(sql("Related[Jedi+more evil = yes] && Jedi+deadliness > 10"))
      .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year,
                   GROUP_CONCAT(r0.object_company_id SEPARATOR '##')
                   FROM relationships AS r0
                   LEFT JOIN answers AS a0 ON
                   r0.object_company_id = a0.company_id && r0.year = a0.year
                   WHERE ((r0.metric_id = #{more_evil_id} && r0.value = "yes")) &&
                   ((a0.metric_id = #{deadliness_id} && a0.numeric_value > 10))
                   GROUP BY r0.subject_company_id, r0.year
                 SQL
  end

  example "inverse metric" do
    expect(sql("Related[Jedi+less evil]"))
      .to eq_sql <<-SQL
                   SELECT r0.object_company_id, r0.year,
                   GROUP_CONCAT(r0.subject_company_id SEPARATOR '##')
                   FROM relationships AS r0
                   WHERE ((r0.inverse_metric_id = #{less_evil_id}))
                   GROUP BY r0.object_company_id, r0.year
                 SQL
  end

  example "inverse metric with or condition" do
    expect(sql("Related[Jedi+less evil || Commons+supplied_by=Tier 1]"))
      .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, 
                   GROUP_CONCAT(r0.object_company_id SEPARATOR '##') 
                   FROM (
                     SELECT rr0.subject_company_id, rr0.object_company_id , 
                            rr0.metric_id, rr0.year, rr0.value 
                     FROM relationships rr0 
                     WHERE rr0.metric_id = #{supplied_by_id} 
                     UNION 
                     SELECT rr1.object_company_id as subject_company_id, 
                            rr1.subject_company_id as object_company_id, 
                            rr1.metric_id, rr1.year, rr1.value 
                     FROM relationships rr1 
                     WHERE rr1.inverse_metric_id = #{less_evil_id}
                   ) AS r0 
                   WHERE ((r0.inverse_metric_id = #{less_evil_id}) 
                   OR (r0.metric_id = #{supplied_by_id} && r0.value = "Tier 1")) 
                   GROUP BY r0.subject_company_id, r0.year
                 SQL
  end

  example "inverse metric and metric" do
    expect(sql("Related[Jedi+less evil && Commons+supplied_by=Tier 1]"))
      .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, 
                   GROUP_CONCAT(r0.object_company_id SEPARATOR '##') 
                   FROM 
                   ( SELECT rr0.object_company_id as subject_company_id, 
                            rr0.subject_company_id as object_company_id, 
                            rr0.metric_id, rr0.year, rr0.value 
                     FROM relationships rr0 
                   ) AS r0 
                   LEFT JOIN relationships AS r1 
                   ON r0.subject_company_id = r1.subject_company_id &&
                      r0.object_company_id = r1.object_company_id && 
                      r0.year = r1.year 
                   WHERE ((r0.inverse_metric_id = #{less_evil_id}) 
                   AND (r1.metric_id = #{supplied_by_id} && r1.value = "Tier 1")) 
                   GROUP BY r0.subject_company_id, r0.year
                 SQL
  end

  example "metric and inverse metric" do
    expect(sql("Related[Commons+supplied_by=Tier 1 && Jedi+less evil]"))
      .to eq_sql <<-SQL
                   SELECT r0.subject_company_id, r0.year, 
                   GROUP_CONCAT(r0.object_company_id SEPARATOR '##') 
                   FROM relationships as r0
                   LEFT JOIN 
                   (
                     SELECT rr1.object_company_id as subject_company_id, 
                            rr1.subject_company_id as object_company_id, 
                            rr1.metric_id, rr1.year, rr1.value 
                     FROM relationships rr1
                     WHERE rr1.inverse_metric_id = #{less_evil_id}
                   ) AS r1 
                   ON r0.subject_company_id = r1.subject_company_id &&
                      r0.object_company_id = r1.object_company_id && 
                      r0.year = r1.year 
                   WHERE ((r0.metric_id = #{supplied_by_id} && r0.value = "Tier 1")
                   AND (r1.inverse_metric_id = #{less_evil_id}) ) 
                   GROUP BY r0.subject_company_id, r0.year
    SQL
  end

  it "doesn't allow '&&' and '||'" do
    expect { sql("Related[Jedi+less evil || Commons+supplied_by=Tier 1 && Jedi+more evil]") }
      .to raise_error "not allowed"
  end
end
