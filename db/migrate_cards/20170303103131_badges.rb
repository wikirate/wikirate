# -*- encoding : utf-8 -*-

class Badges < Card::Migration
  def up
    ensure_card "Badge", type_id: Card::CardtypeID, codename: "badge"
    ensure_card "Badges earned", codename: "badges_earned"
    ensure_card "designer badge", codename: "designer_badge"
    ensure_card "company badge", codename: "company_badge"
    ensure_card "project badge", codename: "project_badge"
    ensure_card "Badge+*right+*update", content: "[[Administrator]]"
    Card::Cache.reset_all
    ["Researcher", "Research Engine", "Research Fellow", "Checker",
     "Check Mate", "Checksquisite",
     "Answer Advancer", "Answer Enhancer", "Answer Romancer",
     "Commentator", "Uncommon Commentator", "High Commentations",
    ].each do |name|
      ensure_card name, type_id: Card::BadgeID
    end


  end
end
