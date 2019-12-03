RSpec.describe Answer, "Answer.search" do
  def search args
    described_class.search args
  end

  it "searches by title" do
    expect(search(title_name: "darkness rating", return: :record))
      .to contain_exactly "Jedi+darkness rating+Death Star",
                          "Jedi+darkness rating+Slate Rock and Gravel Company",
                          "Jedi+darkness rating+Slate Rock and Gravel Company"
  end

  it "can sort by year" do
    result = search(title_name: "darkness rating", return: :record,
                    sort_by: :year, sort_order: :desc)
    expect(result.size).to eq 3
    expect(result.first).to eq "Jedi+darkness rating+Slate Rock and Gravel Company"
  end

  it "can sort by bookmarks" do
    result = search(designer_name: "Jedi", return: :title,
                    sort_by: :bookmarkers, sort_order: :desc)
    expect(result.first).to eq "disturbances in the Force"
    expect(result.last).to eq "deadliness"
  end

  it "can return multiple columns" do
    result = search metric_id: sample_metric(:number).id,
                    return: [:company, :year, :value]
    expect(result)
      .to include ["Death Star", 1977, "100"],
                  ["SPECTRE", 1977, "50"],
                  ["Los Pollos Hermanos", 1977, "40"],
                  ["Slate Rock and Gravel Company", 1977, "20"],
                  ["Slate Rock and Gravel Company", 2005, "10"],
                  ["Samsung", 1977, "Unknown"]
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
