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
     "Commentator", "Uncommon Commentator",
     ["High Commentations", "high_commentations"],
     "Projected Voice", "Project Launcher",
     "Inside Source", "A Cite to Behold", "A Source of Inspiration",
     "Company Register", "The Company Store", "Inc Slinger",
     "Logo Brick", "How Lo can you Go", "Logo and Behold",
     "Metric Creator", "I So Metric", "Helio Metric",
     "Metric Voter", "Metric Critic", "Metric Voting Machine"
    ].each do |name|
      name, codename =
        name.is_a?(Array) ? name : [name, name.to_name.key]

      ensure_card name, type_id: Card::BadgeID, codename: codename
    end

    add_style "badges", type_id: Card::ScssID,
              to: "customized classic skin"
  end
end
