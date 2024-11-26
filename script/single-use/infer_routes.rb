# -*- encoding : utf-8 -*-

require File.expand_path "../../../config/environment", __FILE__
require "colorize"

user = Rails.env.development? ? "Joe Admin" : "Ethan McCutchen"
Card::Auth.signin user

API_USERS = [
  "Vasiliki Gkatziaki",
  "Ethan McCutchen",
  "Philipp Kuehl",
  "Wikirate International e.V.",
  "World Benchmarking Alliance",
  "Fashion Revolution",
  "Organisation for Economic Cooperation & Development (OECD)"
].freeze

def infer_routes
  puts "infer calculated answer"
  ::Answer.where(answer_id: nil).update_all route: route_index(:calculation)
  [Answer, Relationship].each do | klass|
    puts "infer imported (#{klass})"
    klass.where(imported: true).update_all route: route_index(:import)
    if api_user_ids.present?
      puts "infer API (#{klass})"
      klass.where(api_user_condition).update_all route: route_index(:api)
    end
    puts "the rest are direct (#{klass})"
    klass.where(route: nil).update_all route: route_index(:direct)
  end
end

def api_user_condition
  id_list = api_user_ids.join ", "
  "route is null AND (" \
    "editor_id in (#{id_list}) OR " \
    "(editor_id is null and creator_id in (#{id_list}))" \
    ")"
end

def api_user_ids
  API_USERS.map(&:card_id).compact
end

def route_index symbol
  Answer.route_index symbol
end

def populate_relationship_editors
  ActiveRecord::Base.connection.execute(
    "UPDATE relationships r " \
      "JOIN card_actions cn ON r.relationship_id = cn.card_id " \
      "JOIN card_acts ca ON ca.id = cn.card_act_id " \
      "SET editor_id = ca.actor_id, creator_id = ca.actor_id, created_at = ca.acted_at"
  )
end

populate_relationship_editors
infer_routes
