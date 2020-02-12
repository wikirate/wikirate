include_set Abstract::TenScale

def last_content_act
  @last_content_act ||= last_content_action&.act
end

def content_updated_at
  last_content_act&.acted_at || updated_at
end

def content_updater_id
  last_content_act&.actor_id || updater_id
end

def content_updater
  Card[content_updater_id]
end

format :html do
  view :updated_at, compact: true do
    date_view card.content_updated_at
  end

  view :core do
    card.item_names.join(",")
  end

  view :credit do
    return unless card.real?
    wrap_with :div, class: "credit ml-1 pl-1 text-muted" do
      [credit_verb, credit_date, credit_whom].join " "
    end
  end

  view :pretty, unknown: true do
    wrap_with :span, pretty_span_args do
      beautify(pretty_value).html_safe
    end
  end

  # do not link to the relationship answer counts that comprise the "value" of
  # relationship metric answers.
  before :pretty_link do
    voo.hide! :link if card.relationship_count_value?
  end

  view :pretty_link, unknown: true do
    voo.show :link
    wrap_with :span, class: "metric-value", title: card.content do
      pretty_link beautify(pretty_value)
    end
  end



  private

  def pretty_link text
    return text if voo.hide? :link
    link_to text, path: "/#{card.name.left_name.url_key}", target: "_blank",
                  class: "_update-details"
  end

  def pretty_span_args
    span_args = { class: "metric-value" }
    add_class span_args, :small if pretty_value.length > 5
    span_args
  end

  def ten_scale?
    card.left.ten_scale?
  end

  def beautify value
    ten_scale? ? beautify_ten_scale(value) : value
  end

  # link to full action history (includes value history)
  def credit_verb
    link_to_card card.left, "updated", path: { view: :history }, rel: "nofollow"
  end

  def credit_date
    "#{render :updated_at} ago"
  end

  def credit_whom
    "by #{link_to_card card.content_updater}"
  end
end
