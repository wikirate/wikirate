def raw_help_text
  "Verify that the answer accurately represents its source."
end

format :html do
  delegate :answer,
           :allowed_to_check?, :checked?, :user_checked?,
           :other_user_requested_check?, :check_requested?,
           :checkers, :check_requester, :user, :checker_count,
           to: :card

  view :core, template: :haml
  view :check_interaction, cache: :never, template: :haml

  def input_type
    :checkbox
  end

  def option_label_text _option_name
    haml :request_label
  end

  def verb
    answer.editor_id ? "last updated" : "created"
  end

  def checkers_list
    checkers.map { |n| nest n, view: :link }.to_sentence
  end

  # @param text [String] linktext
  # @param flag [Symbol] :check or :uncheck
  def check_button text, flag: :check
    link_to text, class: "btn btn-outline-secondary btn-research slotter",
                  remote: true, rel: "nofollow",
                  href: path(action: :update, set_flag: flag)
  end
end

format :json do
  def atom
    super().merge checks: card.checkers.count, check_requested: card.check_requested?
  end
end
