format :html do
  delegate :answer,
           :allowed_to_check?, :checked?, :user_checked?,
           :other_user_requested_check?, :check_requested?,
           :checkers, :check_requester, :user, :checker_count,
           to: :card

  view :edit_in_form do
    return "" if other_user_requested_check?
    wrap_with(:h5, "#{fa_icon(:flag, class: 'text-muted')} Checks") + super()
  end

  def input_type
    :checkbox
  end

  def option_label_text _option_name
    "request"
  end

  view :input, unknown: true do
    wrap_with :div, class: "d-flex flex-nowrap" do
      super() + popover_link("Not sure? Ask another researcher to double check this.")
    end
  end

  view :core, template: :haml
  view :check_interaction,
       cache: :never, template: :haml, perms: ->(fmt) { fmt.allowed_to_check? }

  def research_params
    @research_params ||=
      inherit(:research_params) ||
      parent.try(:research_params) ||
      card.left&.format&.try(:research_params) || {}
  end

  view :flag, unknown: true do
    card.items.present? ? render_icon : ""
  end

  view :icon do
    if checked?
      double_check_icon
    elsif check_requested?
      request_icon
    else
      ""
    end
  end

  def verb
    answer.editor_id ? "last updated" : "created"
  end

  def checkers_list
    checkers.map { |n| nest n, view: :link }.to_sentence
  end

  view :full_list, cache: :never do
    with_paging do |paging_args|
      wrap_with :div, pointer_items(paging_args.extract!(:limit, :offset)),
                class: "pointer-list"
    end
  end

  def double_check_icon
    fa_icon "check-circle", class: "verify-blue", title: "value checked"
  end

  def request_icon
    fa_icon "flag", class: "request-red", title: "check requested"
  end

  BTN_CLASSES = "btn btn-outline-secondary btn-sm".freeze

  # @param text [String] linktext
  # @param flag [Symbol] :check or :uncheck
  def check_button text, flag: :check
    link_to text, class: "#{BTN_CLASSES} slotter", remote: true, rel: "nofollow",
                  href: path(action: :update, set_flag: flag)
  end

  def fix_link
    link_to_card :research_page, "No, I'll fix it",
                 class: "#{BTN_CLASSES} ml-1",
                 path: { view: :edit }.merge(research_params)
  end
end

format :json do
  def atom
    super().merge checks: card.checkers.count, check_requested: card.check_requested?
  end
end
