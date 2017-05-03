RSpec.describe Answer do
  def search args
    described_class.search args
  end

  it "searches by title" do
    expect(search(title_name: "darkness rating", return: :record))
      .to eq ["Jedi+darkness rating+Death Star",
                      "Jedi+darkness rating+Slate Rock and Gravel Company"]
  end

  it "sorts by year" do
    expect(search(title_name: "darkness rating", return: :record, sort_by: :year))
      .to eq ["Jedi+darkness rating+Death Star",
                      "Jedi+darkness rating+Slate Rock and Gravel Company"]
  end

  it "sorts by importance" do
    result = search(designer_name: "Jedi", return: :title,
                    sort_by: :importance, sort_order: :desc)
    expect(result.first).to eq "disturbances in the Force"
    expect(result.last).to eq "deadliness"
  end
end
