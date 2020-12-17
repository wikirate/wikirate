# -*- encoding : utf-8 -*-

class MultiselectYear < Cardio::Migration
  def up
    ensure_card [:source, :year, :type_plus_right, :input],
                type: :pointer,
                content: "[[multiselect]]"
  end
end
