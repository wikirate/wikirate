
# EVENTS
event :flash_success_message, :finalize, on: :create do
  success.flash format(:html).success_alert
end

format :html do
  # AS RESEARCH PAGE

  # NOCACHE because slot machine manipulates instance variables
  view :open, cache: :never do
    wrap do
      subformat(:research_page).slot_machine metric: card.metric,
                                             company: card.company,
                                             year: card.year
    end
  end

  before :title do
    # HACK: to prevent cancel button on research page from losing title
    voo.title ||= "Answer"
  end

  def success_alert
    alert :success, true, false, class: "text-center" do
      wrap_with :p do
        "Success! To research another answer select a different metric or year."
      end
    end
  end

  view :year_option, unknown: true do
    return unless card.year.present?
    card.known? ? render(:year_and_value) : haml(:new_year_option)
    # merry christmas and a haml new year.
  end

  view :year_selected_option, template: :haml, unknown: true
end
