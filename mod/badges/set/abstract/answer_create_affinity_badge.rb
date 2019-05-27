# abstract set used for affinity badges like
# [Designer]+Researcher+designer_badge or
# [Company]+Research Pro+company_badge

include_set Abstract::AnswerCreateBadge

def virtual?
  true
end

format :html do
  delegate :affinity, :affinity_card, :affinity_type, :badge, to: :card

  view :badge, unknown: true do
    nest(affinity_card, view: :thumbnail) + affinity_subtitle
  end

  def affinity_subtitle
    haml do
      <<-HAML.strip_heredoc
        .text-muted
          = affinity_subtitle_text
      HAML
    end
  end

  def affinity_subtitle_text
    if affinity_type == :designer
      "Metric Designer"
    else
      affinity_type.to_s.capitalize
    end
  end

  view :level do
    wrap_with :div, class: "badge-certificate" do
      wrap_with :div, class: "affinity-badge-container" do
        [
          "<div class='affinity-line'></div><hr/>",
          certificate(badge_level)
        ]
      end
    end
  end

  view :name_with_certificate do
    "#{certificate(badge_level)} <strong>#{affinity}</strong> #{badge}"
  end
end

def badge
  name.parts[1]
end

def badge_key
  self[1].codename.to_sym
end

def affinity
  name.parts[0]
end

def affinity_card
  Card[affinity]
end
