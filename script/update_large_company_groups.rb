# company groups larger than 10K companies are not automatically updated by
# the :update_company_group_lists_based_on_metric event.
#
# This script is for periodic updates (and is to be triggered by a cron job)

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.signin "Ethan McCutchen"

MINIMUM_COMPANY_COUNT = 10_000

def company_group_sql
  "select c.id as group_id from counts ct " \
    "join cards c on ct.left_id = c.id " \
    "where c.type_id = #{:company_group.card_id} " \
    "and ct.right_id = #{:wikirate_company.card_id} " \
    "and value > #{MINIMUM_COMPANY_COUNT};"
end

def each_large_company_group
  ActiveRecord::Base.connection.execute(company_group_sql).each do |row|
    yield row.first.card
  end
end

def update_group? group
  m_ids = metric_ids_for_group group
  return false unless m_ids.present?

  Answer.where(metric_id: m_ids)
        .where("updated_at > now() - interval 1 day")
        .count.positive?
end

def metric_ids_for_group group
  spec = group.specification_card
  return unless spec.implicit?
  Card.search type: :metric, referred_to_by: spec.id, return: :id
end

each_large_company_group do |group|
  update_group? group
  list = group.wikirate_company_card
  list.update_content_from_spec
  list.save!
end
