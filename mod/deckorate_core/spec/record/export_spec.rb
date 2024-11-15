RSpec.describe Record::Export do
  let :record do
    Card["Jedi+more evil+Death Star+1977"]
  end

  it "renders csv line" do
    expect(CSV.generate_line(record.record.csv_line))
      .to match(/\d+,Jedi\+more evil,Death Star,1977,\d+/)
  end
end
