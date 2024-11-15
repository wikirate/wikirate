RSpec.describe Card::Set::TypePlusRight::Metric::Relationship do
  def card_subject
    "Jedi+more evil".card.fetch :relationship
  end

  # views used in csv / json exports
  check_views_for_errors views: %i[titled detailed], format: :csv
  check_views_for_errors views: %i[titled detailed], format: :json

  context "when filtering for year and company group (as fashionchecker does)" do
    def json_no_errors_with_filter filter
      Card::Env.with_params filter: filter do
        expect_view(:molecule, format: :json).to lack_errors
      end
    end

    example "with specific year" do
      json_no_errors_with_filter year: "1977", company_group: "Deadliest"
    end

    example "with latest year" do
      json_no_errors_with_filter year: "latest", company_group: "Deadliest"
    end
  end
end
