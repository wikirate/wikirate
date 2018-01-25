describe Card::Set::Self::ResearchPage do
  specify do
    page = Card[:research_page].format
                               .slot_machine metric: "Joe User+researched",
                                             company: "Death Star",
                                             year: "2014"
    expect(page).to have_tag ".metric"
  end
end
