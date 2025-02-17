include_set Abstract::SocialMedia

LEGAL_CODENAMES = %i[policy privacy_policy terms_of_use].freeze
# community_guidelines disclaimers notice_and_take_down

format :html do
  view :core, template: :haml, cache: :deep

  def footer_legal_link_list
    LEGAL_CODENAMES.map do |codename|
      link_to_card codename
    end << impressum_link
  end

  def impressum_link
    link_to "Impressum", title: "Impressum", target: "_legal",
                         href: "https://wikirate-intl.org/Impressum"
  end
end
