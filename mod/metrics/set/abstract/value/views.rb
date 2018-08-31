format :html do
  view :core do
    card.item_names.join(",")
  end

  view :credit do
    return unless card.real?
    wrap_with :div, class: "credit ml-1 pl-1 text-muted" do
      [credit_verb, credit_date, credit_whom].join " "
    end
  end

  private

  # link to full action history (includes value history)
  def credit_verb
    link_to_card card.left, "updated", path: { view: :history }, rel: "nofollow"
  end

  def credit_date
    "#{render :updated_at} ago"
  end

  def credit_whom
    "by #{link_to_card card.updater}"
  end
end
