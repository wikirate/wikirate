# -*- encoding : utf-8 -*-

class AddHybridFlag < Card::Migration
  def up
    ensure_trait "hybrid", :hybrid,
                 default: { type_id: Card::ToggleID },
                 help: "Allow calculated answers to be overridden based on sourced "\
                       "research."
  end
end
