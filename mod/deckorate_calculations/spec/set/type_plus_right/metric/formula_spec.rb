# encoding: UTF-8

RSpec.describe Card::Set::TypePlusRight::Metric::Formula do
  def card_subject
    Card["Jedi+deadliness+Joe User+formula"]
  end

  check_views_for_errors

  it "show input options in formula" do
    expect_view(:titled, card: "Jedi+deadliness average+formula")
      .to have_tag("div.metric-tree-item-title") do
        with_tag "div.thumbnail", with: { "data-card-name": "Jedi+deadliness" }
        # with_tag "div.input-variable-options", /year.*-2..0/m
      end
  end

  def calc_answer metric_title="formula test", company_name=nil, year=1977
    company_id ||= (company_name || "Death Star").card_id
    Answer.where(metric_id: "Jedi+#{metric_title}".card_id,
                 company_id: company_id,
                 year: year).take
  end

  def answer_value metric_title="formula test", company_name=nil, year=1977
    calc_answer(metric_title, company_name, year)&.value
  end

  def updates_answer_with_delay from: nil, to:, metric_title: "formula test", &block
    with_delayed_jobs do
      expect_answer_not_to_change from, metric_title, &block
    end
    expect(answer_value(metric_title)).to match(to)
    expect(calc_answer(metric_title).calculating).to be_falsey
  end

  def expect_answer_not_to_change value, metric_title
    expect(answer_value(metric_title)).to match(value) if value
    yield
    expect(answer_value(metric_title)).to match(value) if value
  end

  context "when formula is updated" do
    it "updates values" do
      updates_answer_with_delay from: /^0.01/, to: /^5.01/,
                                metric_title: "friendliness" do
        Card["Jedi+friendliness+formula"].update! content: "1/m1 + 5"
      end
    end

    it "updates values of dependent calculated metric" do
      updates_answer_with_delay from: /^0.02/, to: /^10.02/,
                                metric_title: "double friendliness" do
        Card["Jedi+friendliness+formula"].update! content: "1/m1+5"
      end
    end

    context "with different variables" do
      before do
        with_delayed_jobs do
          Card["Jedi+friendliness"].update! fields: {
            variables: [{ metric: "Joe User+researched number 1", name: "m1" }].to_json,
            formula: "7 * m1"
          }
        end
      end

      it "creates answer for company/year not previously covered" do
        expect(answer_value("friendliness", "Apple Inc", 2015)).to eq("700")
      end

      it "removes answer for company no longer covered" do
        expect(answer_value("friendliness", "SPECTRE")).to eq(nil)
      end
    end

    context "with scores as variables" do
      before do
        with_delayed_jobs do
          Card["Jedi+friendliness"].update! fields: {
            variables: [
              { metric: "Jedi+disturbances in the Force+Joe User", name: "m1" }
            ].to_json,
            formula: "3 * m1"
          }
        end
      end

      it "creates answer for company/year not previously covered" do
        expect(answer_value("friendliness", "Monster Inc", 2000)).to eq("30")
      end
    end
  end

  it "calculates values if formula is added after creation" do
    name = "Jedi+formula test"
    updates_answer_with_delay to: /^322/ do
      create_metric name: name, type: :formula
      name.card.update! fields: {
        variables: [
          { metric: "Jedi+deadliness", name: "m1" },
          { metric: "Jedi+Victims by Employees", name: "m2" }
        ].to_json,
        formula: "m1 / m2"
      }
    end
  end

  example "formula with formula input" do
    create_metric name: "Jedi+triple friendliness",
                  type: :formula,
                  formula: "m1 * 3",
                  variables: [{ metric: "Jedi+friendliness", name: "m1" }].to_json
    expect(answer_value("triple friendliness")).to match /0.03/
  end

  context "when researched input changed" do
    def change_research_input
      update_card "Jedi+deadliness+Death Star+1977+value", content: "10"
      researched_value = answer_value "deadliness"
      expect(researched_value).to eq "10"
    end

    it "updates calculated values" do
      expect(answer_value("friendliness")).to eq "0.01"
      change_research_input
      expect(answer_value("friendliness")).to eq "0.1"
    end

    it "updates second level formula" do
      expect(answer_value("double friendliness")).to eq "0.02"
      change_research_input
      expect(answer_value("double friendliness")).to eq "0.2"
    end
  end
end
