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
  def raw_help_text
    [metric_card.question, methodology_link].join " <br/>"
  end

  view :updated_at, compact: true do
    date_view card.content_updated_at
  end

  view :core, unknown: true, cache: :yes do
    wrap_with :span, pretty_span_args do
      beautify(pretty_value).html_safe
    end
  end

  view :credit, unknown: true do
    return "" if card.new?
    title = [credit_verb, credit_date, credit_whom].join(" ")
    wrap_with :div, class: "credit text-muted", title: title do
      nest card.content_updater, view: :thumbnail_no_subtitle, size: :icon
    end
  end

  view :pretty, unknown: true do
    render_core
  end

  private

  def methodology_link
    link_to "Methodology", path: "#", class: "_methodology-link"
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
    "updated"
    # link_to_card card.left, "updated", path: { view: :history }, rel: "nofollow"
  end

  def credit_date
    "#{render :updated_at} ago"
  end

  def credit_whom
    "by #{card.content_updater}"
  end
end
