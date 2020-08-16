RSpec.describe Answer, "Answer.search" do
  def search args
    described_class.search args
  end

  def record_names args
    search(args.merge(return: %i[metric_id company_id])).map do |array|
      Card::Name[*array]
    end
  end

  it "searches by title" do
    expect(record_names(title_id: "darkness rating".card_id))
      .to contain_exactly "Jedi+darkness rating+Death Star",
                          "Jedi+darkness rating+Slate Rock and Gravel Company",
                          "Jedi+darkness rating+Slate Rock and Gravel Company"
  end

  it "can sort by year" do
    result = record_names(title_id: "darkness rating".card_id,
                          sort_by: :year, sort_order: :desc)
    expect(result.size).to eq 3
    expect(result.first).to eq "Jedi+darkness rating+Slate Rock and Gravel Company"
  end

  it "can sort by bookmarks" do
    result = search(designer_id: "Jedi".card_id, return: :metric_id,
                    sort_by: :bookmarkers, sort_order: :desc)
    expect(result.first.card.metric_title).to eq "disturbances in the Force"
  end

  it "can return multiple columns" do
    result = search metric_id: sample_metric(:number).id,
                    return: [:company_id, :year, :value]
    expect(result)
      .to include ["Death Star".card_id, 1977, "100"],
                  ["SPECTRE".card_id, 1977, "50"],
                  ["Los Pollos Hermanos".card_id, 1977, "40"],
                  ["Slate Rock and Gravel Company".card_id, 1977, "20"],
                  ["Slate Rock and Gravel Company".card_id, 2005, "10"],
                  ["Samsung".card_id, 1977, "Unknown"]
  end

  it "can count" do
    expect(search(year: "2000", return: :count)).to eq 16
  end

  it "can uniquify and return count" do
    result = search year: "2000", uniq: :company_id, return: :count
    expect(result).to eq 7
  end

  # it "can uniquify and return different column" do
  #   result = search year: "2000", uniq: :company_id, return: :company_name
  #   expect(result).to eq %w[Apple_Inc Death_Star Monster_Inc
  #                           Slate_Rock_and_Gravel_Company SPECTRE]
  # end
end
