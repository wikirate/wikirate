
# EVENTS
event :flash_success_message, :finalize, on: :create do
  success.flash format(:html).success_alert
end

format :html do
  # AS RESEARCH PAGE

  # NOCACHE because slot machine manipulates instance variables
  view :open do
    wrap do
      subformat(:research_page).slot_machine metric: card.metric,
                                             company: card.company,
                                             year: card.year # active_tab: "View Source"
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

  view :research_button, unknown: true do
    return "" unless metric_card.user_can_answer?
    link_to_card :research_page, "Research answer",
                 target: "_blank",
                 class: "btn btn-primary btn-sm research-answer-button",
                 path: { metric: card.metric, company: card.company },
                 title: "Research answer"
  end

  view :year_option, unknown: true do
    return unless card.year.present?
    card.new? ? haml(:new_year_option) : render(:year_and_value)
  end

  view :year_selected_option, template: :haml, unknown: true
end
