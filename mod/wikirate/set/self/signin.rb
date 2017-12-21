format :html do
  def default_title_args _args
    voo.title ||= "Log in"
  end

  def default_core_args args={}
    args[:buttons] = button_tag "Log in"
    if Card.new(type_id: Card::SignupID).ok? :create
      args[:buttons] +=
        link_to("...or Join!", path: { action: :new, mark: :signup })
    end
    reset_path_opts = { slot: { hide: :toolbar } }
    reset_link = link_to_view :edit, "RESET PASSWORD", path: reset_path_opts
    args[:buttons] += raw("<div style='float:right'>#{reset_link}</div>")
    # FIXME: - hardcoded styling
    args
  end
end
