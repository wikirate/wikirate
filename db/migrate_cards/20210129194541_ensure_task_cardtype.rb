# -*- encoding : utf-8 -*-

class EnsureTaskCardtype < Cardio::Migration
  def up
    ensure_code_card "Task", type: "Cardtype"
    ensure_code_card "Why"
    ensure_code_card "How To"

    Card["Task+*type+*children"]&.delete!
    ensure_card ["Task", :search_type, :type_plus_right, :default], type: "Search"
  end
end
