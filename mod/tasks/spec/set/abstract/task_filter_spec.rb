RSpec.describe Card::Set::Abstract::TaskFilter do
  let :sample do
    Card.fetch "Add a Company Logo+Company"
  end

  it "takes CQL from the search card" do
    expect(sample.task_cql[:type]).to eq("Company")
  end
end
