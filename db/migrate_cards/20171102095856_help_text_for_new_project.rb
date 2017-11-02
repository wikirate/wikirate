# -*- encoding : utf-8 -*-

class HelpTextForNewProject < Card::Migration
  def up
    ensure_card "project+metric+*type plus right+*add help",
                content: "These are the Metrics covered by the initiative"
  end
end
