# couldn't get this to work by adding it to abstract metric answer :(
include_set Abstract::DesignerPermissions

# this has to be on a type set for field events to work
require_field :value, when: :value_required?
require_field :source, when: :source_required?

delegate :value_required?, to: :metric_card

def unpublished_option?
  steward? && !metric_card.unpublished
end

# EVENTS
event :flash_success_message, :finalize, on: :create do
  success.flash format(:html).success_alert
end

format :html do
  view :research_button, unknown: true do
    record_card.format.research_button year_name
  end

  view :edit_inline do
    voo.buttons_view = :edit_answer_buttons
    super()
  end

  view :simple_new do
    voo.buttons_view = :submit_answer_button
    super()
  end

  view :submit_answer_button do
    button_formgroup { submit_answer_button }
  end

  view :edit_answer_buttons do
    button_formgroup do
      [submit_answer_button, cancel_answer_button, delete_button]
    end
  end

  view :read_form_with_button, wrap: :slot, template: :haml

  view :new do
    "Answers are created via the Research Page."
  end

  def cancel_answer_button
    link_to_view :read_form_with_button, "Cancel",
                 class: "btn btn-outline-secondary btn-research btn-sm"
  end

  def delete_button
    super class: "btn-research" if card.ok? :delete
  end

  def submit_answer_button
    standard_save_button text: "Submit Answer", class: "btn-research"
  end

  def edit_fields
    standard_edit_fields.tap do |fields|
      fields.unshift [:year, title: "Year"] if card.real? && @nest_mode == :edit
      fields << [:unpublished, title: "Unpublished"] if card.unpublished_option?
    end
  end

  def standard_edit_fields
    [
      [card.value_card, title: "Answer"],
      [:source, title: "Source",
                input_type: :removable_content,
                view: :removable_content],
      [:discussion, title: "Comments", show: :comment_box],
      [:checked_by, title: "Checks"]
    ]
  end

  def success_alert
    alert :success, true, false, class: "text-center" do
      haml :success_alert
    end
  end
end
