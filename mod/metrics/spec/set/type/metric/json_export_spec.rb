RSpec.describe Card::Set::Type::Metric, "json export" do
  subject do
    render_view :atom, { name: "Joe User+researched number 2" }, format: :json
  end

  let(:metric) { Card["Joe User+researched number 2"] }

  specify "core view" do
    is_expected.to include(
      a_hash_including(
        name: "Joe User+researched number 2+Samsung+2014",
        value: "5",
        year: "2014",
        company: a_hash_including(name: "Samsung"),
        metric: a_hash_including(designer: "Joe User"),
        source: a_hash_including(source_url: "http://www.wikiwand.com/en/Opera")
      ),
      a_hash_including(name: "Joe User+researched number 2+Samsung+2015",
                       value: "2",
                       year: "2015")
    )
  end
end
