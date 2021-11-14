RSpec.describe Answer::Export do
  let :answer do
    Card["Jedi+more evil+Death Star+1977"]
  end

  it "renders csv line" do
    expect(answer.answer.csv_line)
      .to match(/\d+,Jedi\+more evil,Death Star,1977,\d+/)
  end
end
