# couldn't get this to work by adding it to abstract answer :(
include_set Abstract::StewardPermissions

card_accessor :flag

# this has to be on a type set for field events to work
require_field :value, when: :value_required?
require_field :source, when: :source_required?

delegate :value_required?, to: :metric_card

def stewarded_card
  metric_card
end

def unpublished_option?
  steward? && !metric_card.unpublished
end

# EVENTS
event :flash_success_message, :finalize, on: :create do
  success.flash format(:html).success_alert
end

format :html do
  view :research_button, unknown: true do
    tab = card.real? ? :answer_phase : nil
    text = card.new? ? "Research" : "Review"
    research_button tab: tab, text: text
  end

  view :flag_button do
    modal_link "Flag!",
               path: { mark: :flag,
                       action: :new,
                       card: { fields: { ":subject": card.name } } },
               class: "btn btn-outline-danger #{classy 'flag-button'}"
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

  view :research_option, perms: :none, template: :haml

  view :verification, template: :haml

  view :read_form_with_button, wrap: :slot, template: :haml

  view :new do
    research_page_link = research_button text: "Research Page"
    "Answers are created via the #{research_page_link}."
  end

  def research_button tab: nil, text: "Research Page"
    record_card.format.research_button year: year_name, tab: tab, text: text
  end

  def cancel_answer_button
    link_to_view :read_form_with_button, "Cancel",
                 class: "btn btn-outline-secondary btn-lg"
  end

  def delete_button
    super class: "btn-lg" if card.ok? :delete
  end

  def submit_answer_button
    standard_save_button text: "Submit Answer", class: "btn-lg"
  end

  def edit_fields
    super + [year_field, unpublished_field].compact
  end

  def year_field
    [:year, title: "Year"] if card.real? && @nest_mode == :edit
  end

  def unpublished_field
    [:unpublished, title: "Unpublished"] if card.unpublished_option?
  end

  def success_alert
    alert :success, true, false, class: "text-center" do
      haml :success_alert
    end
  end
end
