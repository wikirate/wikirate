# -*- encoding : utf-8 -*-

class EnsureTaskCardtype < Cardio::Migration::Transform  def up
    Card["Task+*type+*children"]&.delete!
    ensure_card ["Task", :search_type, :type_plus_right, :default], type: "Search"
  end
end
