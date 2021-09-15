RSpec.xdescribe Card::Set::TypePlusRight::Metric::MetricAnswer::Stats do
  describe "view: stats" do
    example "filtered by 'all'" do
      Card.fetch("Jedi+disturbances in the Force").create_answers true do
        SPECTRE "2010" => "Unknown"
        Monster_Inc "2010" => "Unknown"
      end

      expect(stats(status: :all)).to have_tag :table do
        with_tag :tr, count: 4
        with_row "", :known, 11, "Known"
        with_row "+", :unknown, 2, "Unknown"
        with_row "+", :none, 16, "Not Researched"
        with_row "=", :total, "29", "Total"
      end
    end

    example "restricted to a year" do
      Card.fetch("Jedi+disturbances in the Force").create_answers true do
        SPECTRE "1977" => "Unknown"
      end
      html = stats(year: "1977", status: :all)
      expect(html).to have_tag :tr, count: 4
      expect(html)
        .to have_table known: 3, unknown: 1, none: 16, total: 20
    end

    example "filtered by 'researched'" do
      expect(stats(status: :exists))
        .to have_table known: 11, unknown: 0, total: 11
    end
  end

  def stats filter
    Card::Env.params[:filter] = filter
    name = "Jedi+disturbances in the Force+answer"
    Card.expire name # needed because empty @filter_hash is cached on card
    Card.fetch(name).format._render_stats
  end

  def with_row operand, cat, count, label
    with_tag :tr do
      with_tag :td, operand
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
