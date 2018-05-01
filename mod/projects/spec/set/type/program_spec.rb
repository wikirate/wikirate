
describe Card::Set::Type::Program do
  %i[open_content listing edit metric_tab project_tab].each do |view|
    describe "view: #{view}" do
      it "has no errors" do
        expect_view(view).to lack_errors
      end
    end
  end
end
