#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  def self.research_badges bronze, silver, gold
    { researcher: bronze,
      research_engine: silver,
      research_fellow: gold }
  end

  add_badge_set :check,
                checker: 1,
                check_pro: 50,
                check_mate: 250,
                &type_plus_right_count(MetricValueID, CheckedByID, :refer_to)

  add_badge_set :update,
                answer_chancer: 1,
                answer_enhancer: 25,
                answer_advancer: 100,
                &type_plus_right_count(MetricValueID, ValueID, :updated_by)

  add_badge_set :discuss,
                commentator: 1,
                commentatry_team: 50,
                expert_commentary: 250,
                &type_plus_right_edited_count(MetricValueID, DiscussionID)

  add_affinity_badge_set :create,
                         general: research_badges(1, 50, 100),
                         designer: research_badges(10, 100, 250),
                         company: research_badges(3, 50, 100),
                         project: research_badges(5, 75, 150)
end
