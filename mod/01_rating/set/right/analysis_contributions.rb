format :html do
  def analysis_name
    @analysis_name ||= card.cardname.left_name
  end

  def analysis_card
    @analysis_card ||= card.left
  end

  def link_with_params label, analysis_card, text, array
    company = CGI.escape(analysis_card.left.name)
    topic = CGI.escape(analysis_card.right.name)
    sign = array ? "[]" : ""
    params = "wikirate_company#{sign}=#{company}&wikirate_topic#{sign}=#{topic}"
    <<-HTML
      <a href="/#{label}?#{params}">#{text}</a>
    HTML
  end

  def link content, label
    text = %(
          <div class="content">
            #{content}<div class="name">#{label}</div>
          </div>
        )
    case label
    when "Notes", "Sources"
      link_with_params(label, analysis_card, text, true)
    when "Metrics"
      link_with_params(label, analysis_card, text, false)
    when "Overview"
      card_link analysis_name.s, text: text
    end
  end

  def data_item content, label, type=:default
    extra_class =
      case type
      when :highlight then "btn btn-highlight"
      when :warning   then "warning"
      else
        "btn btn-default"
      end
    content_tag :div, class: "contribution #{extra_class if extra_class}" do
      link content, label
    end
  end

  view :core do |_args|
    overview_card = Card.fetch analysis_name.trait(:overview)
    if !analysis_card
      claim_cnt = source_cnt = metric_cnt = 0
    else
      claim_cnt = (claims = Card.fetch(analysis_name.trait(:claim))) &&
                  claims.cached_count
      source_cnt = (sources = Card.fetch(analysis_name.trait(:source))) &&
                   sources.cached_count
      metric_cnt = (metrics = Card.fetch(analysis_name.trait(:metric))) &&
                   metrics.cached_count
    end
    empty = glyphicon "plus"
    data = []
    if claim_cnt == "0"
      data << ['<i class="fa fa-exclamation-circle"></i>', "Need Notes",
               :warning]
      data << [empty, "Notes", :highlight]
    else
      icon =
        if overview_card
          nest(Card.fetch("venn icon"), view: :content, size: :small)
        else
          empty
        end
      data << [icon, "Overview", (:highlight unless overview_card)]
      data << [metric_cnt, "Metrics"]
      data << [claim_cnt, "Notes"]
    end
    data << [(source_cnt == "0" ? empty : source_cnt),
             "Sources", (:highlight if source_cnt == "0")]
    # reverse because of float:right
    data.reverse.map { |opts| data_item(*opts) }.join "\n"
  end
end
