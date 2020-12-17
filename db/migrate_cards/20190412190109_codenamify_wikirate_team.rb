# -*- encoding : utf-8 -*-

class CodenamifyWikirateTeam < Cardio::Migration
  def up
    ensure_card "WikiRate Team", codename: :wikirate_team
  end
end
