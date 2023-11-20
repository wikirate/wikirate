include_set Abstract::SocialMedia

LEGAL_CODENAMES = %i[
  community_guidelines privacy_policy terms_of_use disclaimers notice_and_take_down
].freeze

format :html do
  view :core, template: :haml

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
