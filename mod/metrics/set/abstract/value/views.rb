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

  view :pretty do
    span_args = { class: "metric-value" }
    add_class span_args, grade if ten_scale?
    add_class span_args, :small if pretty_value.length > 5
    wrap_with :span, span_args do
      beautify(pretty_value).html_safe
    end
  end

  before :pretty_link do
    voo.hide! :link if metric_card.relationship? && left.type_id == Card::MetricAnswerID
  end

  view :pretty_link do
    voo.show :link
    text = beautify(pretty_value)
    wrap_with :span, class: "metric-value", title: card.content do
      if voo.hide? :link
        text
      else
        link_to(text, path: "/#{card.name.left_name.url_key}", target: "_blank")
      end
    end
  end

  # for override
  def pretty_value
    @pretty_value ||= card.value
  end

  private

  def ten_scale?
    card.left.ten_scale?
  end

  def beautify value
    ten_scale? ? beautify_ten_scale(value) : value
  end

  def beautify_ten_scale value
    colorify shorten_ten_scale(value)
  end

  def shorten_ten_scale value
    return value if value.number?
    Answer.unknown?(value) ? "?" : "!"
  end

  def grade
    return unless (value = card.value&.to_i)
    case value
    when 0, 1, 2, 3 then :low
    when 4, 5, 6, 7 then :middle
    when 8, 9, 10 then :high
    end
  end

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
