#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  def self.research_badges bronze, silver, gold
    { researcher: bronze,
      research_engine: silver,
      research_fellow: gold }
  end

  add_affinity_badge_set :create,
                         general: research_badges(1, 50, 100),
                         designer: research_badges(10, 100, 250),
                         company: research_badges(3, 50, 100),
                         project: research_badges(5, 75, 150)

  add_badge_set :check,
                checker: 1,
                check_mate: 50,
                checksquisite: 250,
                &type_plus_right_count(MetricValueID, CheckedByID, :refer_to)

  add_badge_set :update,
                answer_advancer: 1,
                answer_enhancer: 25,
                answer_romancer: 100,
                &type_plus_right_count(MetricValueID, ValueID, :updated_by)

  add_badge_set :discuss,
                commentator: 1,
                uncommon_commentator: 50,
                high_commentations: 250,
                &type_plus_right_edited_count(MetricValueID, DiscussionID)
end
