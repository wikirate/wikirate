RSpec.describe Answer do
  def search retrn, args
    described_class.search retrn, args
  end

  def record_names args
    search(%i[metric_id company_id], args).map do |array|
      Card::Name[*array]
    end
  end

  it "searches by metric" do
    expect(record_names(metric_id: "Jedi+darkness rating".card_id))
      .to contain_exactly "Jedi+darkness rating+Death Star",
                          "Jedi+darkness rating+Slate Rock and Gravel Company",
                          "Jedi+darkness rating+Slate Rock and Gravel Company"
  end

  it "can sort by bookmarks" do
    result = described_class.joins(:metric)
                            .where(metrics: { designer_id: "Jedi".card_id })
                            .sort(metric_bookmarkers: :desc)
                            .pluck(:metric_id)
    expect(result.first.card.metric_title).to eq "disturbances in the Force"
  end

  it "can return multiple columns" do
    expect(search %i[company_id year value], metric_id: sample_metric(:number).id)
      .to include ["Death Star".card_id, 1977, "100"],
                  ["SPECTRE".card_id, 1977, "50"],
                  ["Los Pollos Hermanos".card_id, 1977, "40"],
                  ["Slate Rock and Gravel Company".card_id, 1977, "20"],
                  ["Slate Rock and Gravel Company".card_id, 2005, "10"],
                  ["Samsung".card_id, 1977, "Unknown"]
  end

  it "can count" do
    expect(search :count, year: "2000").to eq 16
  end

  it "can uniquify and return count" do
    expect(search :count, year: "2000", uniq: :company_id).to eq 7
  end

  # it "can uniquify and return different column" do
  #   result = search year: "2000", uniq: :company_id, return: :company_name
  #   expect(result).to eq %w[Apple_Inc Death_Star Monster_Inc
  #                           Slate_Rock_and_Gravel_Company SPECTRE]
  # end
end
