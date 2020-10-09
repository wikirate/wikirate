RSpec.describe Card::Set::Type::Source::Json do
  def card_subject
    Card[:darth_vader_source]
  end

  specify "view: atom" do
    expect_view(:atom, format: :json)
      .to include(codename: :darth_vader_source,
                  report_type: "Force Report",
                  file_url: "http://wikirate.org#{card_subject.file_card.file.url}")
  end
end
