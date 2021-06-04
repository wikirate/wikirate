RSpec.describe Card::MetricQuery do
  def run query
    described_class.new(query).run
  end

  example "simple filter" do
    expect(run(designer_id: "Jedi".card_id).map(&:metric_designer).uniq)
      .to eq(["Jedi"])
  end

  example "card id mapping" do
    expect(run(designer: "Jedi").map(&:metric_designer).uniq)
      .to eq(["Jedi"])
  end

  example "topic filter" do
    expect(run(topic: "Taming").map(&:name))
      .to eq(["Fred+dinosaurlabor", "Joe User+researched number 3"])
  end
end
