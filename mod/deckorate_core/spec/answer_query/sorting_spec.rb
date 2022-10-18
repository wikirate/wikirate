RSpec.describe Card::AnswerQuery::Sorting do
  include_context "answer query"

  let(:answer_parts) { [1, -1] }
  let(:default_filters) { { company_id: "Death Star".card_id, year: :latest } }
  let(:sorted_designer) { ["Commons", "Fred", "Jedi", "Joe User"] }

  let :latest_answers_by_bookmarks do
    [
      "disturbances in the Force+2001", "Victims by Employees+1977",
      "Sith Lord in Charge+1977", "dinosaurlabor+2010", "cost of planets destroyed+1977",
      "friendliness+1977", "deadliness+1977", "deadliness+1977",
      "disturbances in the Force+2001", "darkness rating+1977", "descendant 1+1977",
      "descendant 2+1977", "descendant hybrid+1977", "double friendliness+1977",
      "researched number 1+1977", "know the unknowns+1977",
      "more evil+1977", "RM+1977", "deadliness+1977", "Company Category+2019"
    ]
  end

  # @return [Array] of answer cards
  def sort_by sort_by, sort_dir: :asc, researched_only: false
    query = { year: :latest }
    query[:metric_type] = "Researched" if researched_only
    run_query(query, sort_by => sort_dir)
  end

  def sort_designers dir
    sort_by(:metric_designer, sort_dir: dir).map { |a| a.name.parts.first }.uniq
  end

  it "sorts by designer name (asc)" do
    expect(sort_designers(:asc)).to eq(sorted_designer)
  end

  it "sorts by designer name (desc)" do
    expect(sort_designers(:desc)).to eq(sorted_designer.reverse)
  end

  it "sorts by title" do
    sorted = sort_by(:metric_title).map { |a| a.name.parts.second }
    indices =
      ["cost of planets destroyed", "darkness rating", "deadliness",
       "researched number 1", "Victims by Employees"].map do |t|
        sorted.index(t)
      end
    expect(indices).to eq [1, 2, 3, 16, 19]
  end

  it "sorts by recently updated" do
    expect(sort_by(:updated_at, sort_dir: :desc, researched_only: true).first.name)
      .to eq "Fred+dinosaurlabor+Death_Star+2010"
  end

  it "sorts by bookmarkers" do
    actual = altered_results { sort_by :metric_bookmarkers, sort_dir: :desc }
    expected = latest_answers_by_bookmarks

    bookmarked = (0..1)
    not_bookmarked = (2..-1)

    expect(actual[bookmarked]).to contain_exactly(*expected[bookmarked])
    expect(actual[not_bookmarked]).to contain_exactly(*expected[not_bookmarked])
  end
end
