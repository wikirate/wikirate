require File.expand_path("../../../config/environment", __FILE__)

class AwardBadges
  # disable_ddl_transaction!
  class << self
    def up
      Card::Auth.as_bot do
        award_badges_by_user
        award_answer_create_badges
        [:project, :source, :metric, :wikirate_company].each do |type_code|
          award_create_badges type_code
        end
      end
    end

    def user_ids
      @user_ids ||= Card.search(type_id: Card::UserID, return: :id)
    end

    def award_answer_create_badges
      [:project, :company, :designer].each do |affinity_type|
        puts "answer create #{affinity_type} badges"
        award_affinity_answer_badges affinity_type
      end
      puts "answer create general badges"
      award_create_badges :metric_value,
                          from: "answers", where: "", affinity: :general
    end

    def award_create_badges type_code, opts={}
      puts "create badges for #{type_code}"

      type_id = Card::Codename.id type_code
      where ||= opts[:where] || "type_id = #{type_id}"
      where = "WHERE (#{where})" unless where.empty?
      min = min ? "HAVING COUNT(*) > #{min}" : ""
      from ||= opts[:from] || "cards"
      query(
        "SELECT creator_id, COUNT(*) FROM #{from} #{where} GROUP BY creator_id "\
      "#{min}"
      ).each do |user_id, count|
        next unless user_id
        award_badges_if_earned! count, user_id, type_code, opts[:affinity]
      end
    end

    def award_badges_by_user
      puts "rest"
      user_ids.each do |user_id|
        award_badges_for_user user_id
      end
    end

    def award_badges_for_user user_id
      { metric: :vote, metric_value: [:check, :discuss, :update],
        project: :discuss, wikirate_company: :logo }.each do |type, actions|
        Array(actions).each do |action|
          badge_names = Card::Set::Abstract::BadgeSquad
                        .for_type(type)
                        .all_earned_badges action, nil, nil, user_id
          award_badges! user_id, type, badge_names
        end
      end
    end

    def award_affinity_answer_badges affinity_type
      return award_project_affinity_answer_badges if affinity_type == :project
      badge_line = Card::Set::Type::MetricValue::BadgeSquad
                   .badge_line(:create, affinity_type)
      badge_levels = [:bronze, :silver, :gold].map do |level, _h|
        [badge_line.badge(level).threshold, badge_line.badge(level).name]
      end
      min_thresh = badge_line.threshold(:bronze)

      user_ids.each do |user_id|
        affinity_names =
          query("SELECT #{affinity_type}_name, COUNT(*) FROM answers "\
                "WHERE creator_id = #{user_id} "\
                "GROUP BY #{affinity_type}_id HAVING COUNT(*) >= #{min_thresh}")

        badge_levels.each do |threshold, name|
          badge_names = affinity_names.map do |an, count|
            next if count < threshold
            "#{an}+#{name}+#{affinity_type} badge"
          end.compact
          award_badges! user_id, :metric_value, badge_names, true
        end
      end
      # query("SELECT creator_id, #{affinity_type}_name, COUNT(*) FROM answers "\
      #                 "GROUP BY creator_id, #{affinity_type}_id")
      #   .each do |user_id, affinity_name, count|
      #   next unless user_id
      #   award_affinity_answer_badges_if_earned! count, user_id,
      #                                           affinity_type, affinity_name
      # end
    end

    def award_project_affinity_answer_badges
      Card.search(type_id: Card::ProjectID).each do |project|
        next if project.company_ids.empty? || project.metric_ids.empty?
        query("SELECT creator_id, COUNT(*) FROM answers "\
      "WHERE company_id IN (#{project.company_ids.join(',')}) AND"\
      "       metric_id IN (#{project.metric_ids.join(',')})"\
      "GROUP BY creator_id").each do |user_id, count|
          next unless user_id
          award_affinity_answer_badges_if_earned! count, user_id,
                                                  :project, project.name
        end
      end
    end

    def award_affinity_answer_badges_if_earned! count, user_id,
                                                affinity_type, affinity_name
      hierarchy = Card::Set::Abstract::BadgeSquad.for_type(:metric_value)
      badge_names = hierarchy.all_earned_badges(:create, affinity_type, count)
                             .map do |badge_name|
        "#{affinity_name}+#{badge_name}+#{affinity_type} badge"
      end
      award_badges! user_id, :metric_value, badge_names
    end

    def award_badges_if_earned! count, user_id, type_code, affinity=nil
      badge_names = Card::Set::Abstract::BadgeSquad
                    .for_type(type_code).all_earned_badges :create, affinity, count
      award_badges! user_id, type_code, badge_names
    end

    def award_badges! user_id, type_code, badge_names, same_level=false
      return unless badge_names.present?
      name_parts = [Card.fetch_name(user_id), type_code, :badges_earned]
      card = Card.fetch name_parts, new: { type_id: Card::PointerID }
      puts "award to #{card.name} badges #{badge_names}"

      if same_level
        card.add_batch_of_badges badge_names
      else
        badge_names.each do |badge_name|
          card.add_badge_card Card.fetch(badge_name)
        end
      end

      card.save!
    end

    def query sql
      ActiveRecord::Base.connection.exec_query(sql).rows
    end
  end
end

AwardBadges.up
