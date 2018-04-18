RSpec.describe Card::Set::TypePlusRight::Metric::AllMetricValues::Stats do
  describe "view: stats" do
    example "filtered for all" do
      Card.fetch("Jedi+disturbances in the Force").create_values true do
        SPECTRE "2010" => "Unknown"
        Monster_Inc "2010" => "Unknown"
      end

      expect(stats(metric_value: :all)).to have_tag :table do
        with_tag :tr, count: 4
        with_row "", :known, 11, "Known"
        with_row "+", :unknown, 2, "Unknown"
        with_row "+", :not_researched, 14, "Not Researched"
        with_row "=", :total, "27", "Total results"
      end
    end

    example "restricted to a year" do
      Card.fetch("Jedi+disturbances in the Force").create_values true do
        SPECTRE "1977" => "Unknown"
      end
      html = stats(year: "1977", metric_value: :all)
      expect(html).to have_tag :tr, count: 4
      expect(html)
        .to have_table known: 3, unknown: 1, not_researched: 15, total: 18

    end

    example "filtered for researched" do
      expect(stats(metric_value: :researched))
        .to have_table known: 11, unknown: 0, not_researched: 11
    end
  end

  def stats filter
    Card::Env.params[:filter] = filter
    Card.fetch("Jedi+disturbances in the Force", :all_metric_values)
        .format._render_stats
  end

  def with_row op, cat, count, label
    with_tag :tr do
      with_tag :td, op
      with_tag(:td) { with_tag "span.#{cat}.badge", count.to_s }
      with_tag :td, label
    end
  end

  def have_table values
    have_tag :table do
      values.each_pair do |cat, count|
        with_tag "span.#{cat}.badge", count.to_s
      end
    end
  end
end
