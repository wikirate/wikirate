namespace :card do
  namespace :create do
    def set_default_rule_names
      Card::FileCardCreator::ScriptCard.default_rule_name = "script: wikirate scripts"
      Card::FileCardCreator::StyleCard.default_rule_name = "customized classic skin"
    end
  end
end
