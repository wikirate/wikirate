#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  def self.research_badges bronze, silver, gold
    { researcher: bronze,
      research_engine: silver,
      research_fellow: gold }
  end

  hierarchy(
    create: {
      general: research_badges(1, 50, 100),
      designer: research_badges(10, 100, 250),
      company: research_badges(3, 50, 100),
      project: research_badges(5, 75, 150)
    },
    check: {
      checker: 1,
      check_mate: 50,
      checksquisite: 250
    },
    update: {
      answer_advancer: 1,
      answer_enhancer: 25,
      answer_romancer: 100
    },
    discuss: {
      commentator: 1,
      uncommon_commentator: 50,
      high_commentations: 250
    }
  )
end
