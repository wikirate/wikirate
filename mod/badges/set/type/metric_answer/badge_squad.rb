#! no set module

# all badges related to metric answers
class BadgeSquad
  if Card::Codename.exist? :metric_answer
    extend Abstract::BadgeSquad

    def self.research_badges bronze, silver, gold
      { researcher: bronze,
        research_pro: silver,
        research_master: gold }
    end


    add_badge_line :check,
                   checker: 1,
                   check_pro: 50,
                   check_mate: 250,
                   &type_plus_right_count(MetricAnswerID, CheckedByID, :refer_to)

    add_badge_line :update,
                   answer_chancer: 1,
                   answer_enhancer: 25,
                   answer_advancer: 100,
                   &type_plus_right_count(MetricAnswerID, ValueID, :updated_by)

    add_badge_line :discuss,
                   commentator: 1,
                   commentary_team: 50,
                   expert_commentary: 250,
                   &type_plus_right_edited_count(MetricAnswerID, DiscussionID)

    add_affinity_badge_line :create,
                            general: research_badges(1, 50, 100),
                            designer: research_badges(10, 100, 250),
                            company: research_badges(3, 50, 100),
                            project: research_badges(5, 75, 150)
  end
end
