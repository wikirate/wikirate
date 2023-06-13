# -*- encoding : utf-8 -*-

class AddHybridFlag < Cardio::Migration::Transform  def up
    ensure_trait "hybrid", :hybrid,
                 default: { type_id: Card::ToggleID },
                 help: "Allow answers to be directly added or overridden based "\
                       "on sourced research."
  end
end
