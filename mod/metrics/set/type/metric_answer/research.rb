
# EVENTS
event :flash_success_message, :finalize, on: :create do
  success.flash format(:html).success_alert
end

format :html do
  # AS RESEARCH PAGE

  before :title do
    # HACK: to prevent cancel button on research page from losing title
    voo.title ||= "Answer"
  end

  view :submit_answer do
    standard_save_button text: "Submit Answer", class: "btn-research"
  end

  def edit_fields
    [
      [card.value_card, { title: "Answer" }],
      [card.discussion_card, { title: "Comments" }]
    ]
  end

  def success_alert
    alert :success, true, false, class: "text-center" do
      wrap_with :p do
        "Success! To research another answer select a different metric or year."
      end
    end
  end
end
