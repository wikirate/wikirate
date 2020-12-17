# -*- encoding : utf-8 -*-

class UpdateHowToResearchCard < Cardio::Migration
  def up
    merge_cards "how_to_research"
  end
end
