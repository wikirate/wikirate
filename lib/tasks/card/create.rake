namespace :card do
  namespace :create do
    WIKIRATE_DEFAULT_RULE = {
      script: "script: wikirate scripts",
      style: "customized classic skin"
    }.freeze

    def rule_card_name category
      WIKIRATE_DEFAULT_RULE[category]
    end
  end
end
