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
    ["Researcher", "Research Pro", "Research Master", "Checker",
     "Check Pro", "Check Mate",
     "Answer Advancer", "Answer Enhancer", "Answer Chancer",
     "Commentator", "Commentary Team", "Expert Commentary",
     ["Project Q&#38;A", "project_q_a"], "Project Launcher",
     "Inside Source", "A Cite to Behold", "A Source of Inspiration",
     "Company Register", "The Company Store",
     ["Companies (in the) House", "companies_in_the_house"],
     "Logo Adder", "How Lo can you Go", "Logo and Behold",
     "Metric Creator", ["Metric Tonnes", "metric_tonnes"],
     ["Research Agenda-Setter", "research_agenda_setter"],
     "Metric Voter", "Metric Critic", "Metric Connoisseur"
    ].each do |name|
      name, codename =
        name.is_a?(Array) ? name : [name, name.to_name.key]

      ensure_card name, type_id: Card::BadgeID, codename: codename
    end

    add_style "badges", type_id: Card::ScssID,
              to: "customized classic skin"
  end
end
