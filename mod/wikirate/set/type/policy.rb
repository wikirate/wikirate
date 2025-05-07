format :html do
  # override to avoid d0-card-content class in slot
  def prepare_content_slot
    # noop
  end

  view :titled do
    content_tag "div", class: "policy-container py-5" do
      render_content
    end
  end
end
