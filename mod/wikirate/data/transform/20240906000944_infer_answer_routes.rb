# -*- encoding : utf-8 -*-

class InferAnswerRoutes < Cardio::Migration::Transform
  API_USERS = [
    "Vasiliki Gkatziaki",
    "Wikirate International e.V.",
    "World Benchmarking Alliance",
    "Fashion Revolution",
    "Organisation for Economic Cooperation & Development (OECD)"
  ].freeze

  def up
    Answer.where(answer_id: nil).update_all route: route_index(:calculation)
    Answer.where(imported: true).update_all route: route_index(:import)
    if api_user_ids.present?
      Answer.where(api_user_condition).update_all route: route_index(:api)
    end
    Answer.where(route: nil).update_all route: route_index(:direct)
  end

  def api_user_condition
    "route is null and editor_id in (#{api_user_ids.join ', '})"
  end

  def api_user_ids
    API_USERS.map(&:card_id).compact
  end

  def route_index symbol
    Answer::ROUTES.index symbol
  end
end
