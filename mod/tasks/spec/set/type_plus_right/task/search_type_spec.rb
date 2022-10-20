RSpec.describe Card::Set::TypePlusRight::Task::SearchType do
  def card_subject
    Card.fetch "Add a Company Logo+Search"
  end

  it "finds the filter card based on the cql" do
    expect(card_subject.filter_search_name).to eq("Add a Company Logo+Company")
  end

  check_views_for_errors
end
