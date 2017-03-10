# -*- encoding : utf-8 -*-

class AwardBadges < Card::Migration
  disable_ddl_transaction!
  def up
    [:source, :metric, :create, :wikirate_company, :project].each do |type_code|
      award_create_badges type_code
    end
    award_answer_badges
  end

  def award_right_badge right_id, left_type_id
    ActiveRecord::Base.connection.exec_query(
      "SELECT creator_id, COUNT(*) FROM cards c1 #{where} JOIN cards c2 ON c1.left_id = c2.id
       WHERE c2.type_id = #{left_type_id} AND c1.right_id = #{right_id} GROUP BY c1.creator_id"
    )
  end

  def award_create_badges type_code, opts={}
    type_id = Card::Codename[type_code]
    where ||= opts[:where] || "type_id = #{type_id}"
    where = "WHERE (#{where})" unless where.empty?
    from ||= opts[:from] || "cards"
    ActiveRecord::Base.connection.exec_query(
      "SELECT creator_id, COUNT(*) FROM #{from} #{where} GROUP BY creator_id"
    ).each do |user_id, count|
      award_badges_if_earned! count, user_id, type_code
    end
  end

  def award_answer_badges
    award_create_badges :metric_value, from: "answers", where: ""
    [:company, :metric, :project].each do |affinity_type|
      award_affinity_answer_badges affinity_type
    end
  end

  def award_affinity_answer_badges affinity_type
    return award_project_affinity_answer_badges if affinity_type == :project
    ActiveRecord::Base.connection.exec_query(
      "SELECT creator_id, #{affinity}_name, COUNT(*) FROM answers "\
          "GROUP BY creator_id, #{affinity}_id"
    ).each do |user_id, affinity_name, count|
      award_affinity_answer_badges_if_earned! count, user_id,
                                              affinity_type, affinity_name
    end
  end

  def award_project_affinity_answer_badges
    Card.search(type_id: Card::ProjectID).each do |project|
      "SELECT creator_id, COUNT(*) FROM answers "\
      "WHERE company_id IN (#{project.company_ids.join(",")}) AND"\
      "       metric_id IN (#{project.metric_ids.join(",")})"\
      "GROUP BY creator_id"
    end.each do |user_id, count|
      award_affinity_answer_badges_if_earned! count, user_id,
                                              :project, project.name
    end
  end

  def award_affinity_answer_badges_if_earned! count, user_id, affinity_type, affinity_name
    badge_names = Card::Set::Abstract::BadgeHierarchy
                    .for_type(:metric_value)
                    .all_earned_badges(count, :create, affinity).map do |badge_name|
      "#{affinity_name}+#{badge_name}+#{affinity_type} badge"
    end
    award_badges! user_id, :metric_value, badge_names
  end


  def award_badges_if_earned! count, user_id, type_code
    badge_names = Card::Set::Abstract::BadgeHierarchy
                    .for_type(type_code).all_earned_badges count, :create
    award_badges! user_id, type_code, badge_names
  end

  def award_badges! user_id, type_code, badge_names
    return unless badge_names.present?
    name_parts = [Card.fetch_name(user_id), type_code, :earned_badges]
    card = Card.fetch name_parts, new: { type_id: Card::PointerID }
    badge_names.each do |name|
      card.add_item name
    end
    card.save!
  end
end
