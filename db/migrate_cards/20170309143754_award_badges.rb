# -*- encoding : utf-8 -*-

class AwardBadges < Card::Migration
  disable_ddl_transaction!

  def up
    award_answer_create_badges
    [:source, :metric, :wikirate_company, :project].each do |type_code|
      award_create_badges type_code
    end
    award_badges_by_user
  end


  def award_answer_create_badges
    [:company, :metric, :project].each do |affinity_type|
      puts "answer create #{affinity_type} badges"
      award_affinity_answer_badges affinity_type
    end
    puts "answer create general badges"
    award_create_badges :metric_value,
                        from: "answers", where: "", affinity: :general
  end

  def award_create_badges type_code, opts={}
    puts "create badges for #{type_code}"

    type_id = Card::Codename[type_code]
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
    Card.search(type_id: Card::UserID, return: :id).each do |user_id|
      award_badges_for_user user_id
    end
  end

  def award_badges_for_user user_id
    { metric: :vote, metric_value: [:check, :discuss, :update],
      project: :discuss, wikirate_company: :logo }.each do |type, action|
      badge_names = Card::Set::Abstract::BadgeHierarchy
                      .for_type(type)
                      .all_earned_badges action, nil, nil, user_id
      award_badges! user_id, type, badge_names
    end
  end

  def award_affinity_answer_badges affinity_type
    return award_project_affinity_answer_badges if affinity_type == :project
    column_name = affinity_type == :wikirate_company ? :company : affinity_type
    query("SELECT creator_id, #{column_name}_name, COUNT(*) FROM answers "\
                    "GROUP BY creator_id, #{column_name}_id")
      .each do |user_id, affinity_name, count|
      next unless user_id
      award_affinity_answer_badges_if_earned! count, user_id,
                                              affinity_type, affinity_name
    end
  end

  def award_project_affinity_answer_badges
    Card.search(type_id: Card::ProjectID).each do |project|
      query("SELECT creator_id, COUNT(*) FROM answers "\
      "WHERE company_id IN (#{project.company_ids.join(",")}) AND"\
      "       metric_id IN (#{project.metric_ids.join(",")})"\
      "GROUP BY creator_id").each do |user_id, count|
        next unless user_id
        award_affinity_answer_badges_if_earned! count, user_id,
                                                :project, project.name
      end
    end
  end

  def award_affinity_answer_badges_if_earned! count, user_id,
                                              affinity_type, affinity_name
    hierarchy = Card::Set::Abstract::BadgeHierarchy.for_type(:metric_value)
    badge_names = hierarchy.all_earned_badges(:create, affinity_type, count)
                    .map do |badge_name|
      "#{affinity_name}+#{badge_name}+#{affinity_type} badge"
    end
    award_badges! user_id, :metric_value, badge_names
  end

  def award_badges_if_earned! count, user_id, type_code, affinity=nil
    badge_names = Card::Set::Abstract::BadgeHierarchy
                    .for_type(type_code).all_earned_badges :create, affinity, count
    award_badges! user_id, type_code, badge_names
  end

  def award_badges! user_id, type_code, badge_names
    return unless badge_names.present?
    name_parts = [Card.fetch_name(user_id), type_code, :badges_earned]
    card = Card.fetch name_parts, new: { type_id: Card::PointerID }
    puts "award to #{card.name} badges #{badge_names}"
    badge_names.each do |name|
      card.add_item name
    end
    card.save!
  end

  def query sql
    ActiveRecord::Base.connection.exec_query(sql).rows
  end
end
