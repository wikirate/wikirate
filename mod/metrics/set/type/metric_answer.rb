include_set Abstract::MetricChild, generation: 2
include_set Abstract::MetricAnswer

# EVENTS
event :flash_success_message, :finalize, on: :create do
  msg =
    format(:html).alert :success, true, false, class: "text-center" do
      <<-HTML
        <p>Success! To research another answer select a different metric or year.</p>
      HTML
    end
  success.flash msg
end

# AS RESEARCH PAGE
format :html do
  view :open, cache: :never do
    voo.hide! :cited_source_links
    subformat(:research_page).slot_machine metric: card.metric, company: card.company,
                                           year: card.year # active_tab: "View Source"
  end

  before :title do
    # HACK: to prevent cancel button on research page from loosing title
    voo.title ||= "Answer"
  end
end
