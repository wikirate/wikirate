include_set Abstract::SocialMedia

format :html do
  view :core, template: :haml

  def footer_legal_link_list
    { "Policies"    => "Wikirate Policies",
      "Licensing"   => "Licensing",
      "Disclaimers" => "Disclaimers",
      "Privacy"     => "Privacy_Policy",
      "Impressum"   => "https://wikirate-intl.org/Impressum" }
  end
end
