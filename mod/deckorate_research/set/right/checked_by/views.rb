format :html do
  delegate :answer, :allowed_to_check?, :checked?, :user_checked?,
           :checkers, :check_requester, :user, :checker_count, to: :card

  view(:core) { card_form(:update) { haml :core } }
  view :check_interaction, template: :haml, cache: :never,
                           perms: :allowed_to_check?, denial: :blank

  def input_type
    :checkbox
  end

  def verb
    answer.editor_id ? "last updated" : "created"
  end

  def checkers_list
    checkers.map { |n| nest n, view: :link }.to_sentence
  end

  # @param text [String] linktext
  # @param flag [Symbol] :check or :uncheck
  def check_button text, trigger
    link_to text, class: "btn btn-outline-primary btn-lg slotter",
                  remote: true, rel: "nofollow",
                  data: { "disable-with": "Updating..." },
                  href: path(action: :update, card: { trigger: trigger })
  end
end

format :json do
  def atom
    super().merge checks: card.checkers.count
  end
end
