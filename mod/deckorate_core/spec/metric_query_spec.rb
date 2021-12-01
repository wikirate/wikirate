RSpec.describe Card::MetricQuery do
  def run query, sort={}
    described_class.new(query, sort).run
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
    expect(run(topic: "Taming").map(&:name).sort)
      .to eq(["Fred+dinosaurlabor", "Joe User+researched number 3"])
  end

  example "dataset filter" do
    expect(run(dataset: "Evil Dataset").map(&:name).sort)
      .to eq(["Jedi+disturbances in the Force", "Joe User+researched number 2"])
  end

  example "name filter" do
    expect(run(name: "quart").map(&:metric_title))
      .to eq(["Headquarters Location"])
  end

  example "bookmark filter" do
    expect(run(bookmark: "bookmark").map(&:name))
      .to eq(["Jedi+disturbances in the Force"])
  end

  example "bookmark sorting" do
    expect(run({}, bookmarkers: :desc)[0..1].map(&:name))
      .to eq(["Jedi+disturbances in the Force", "Jedi+Victims by Employees"])
  end
end
