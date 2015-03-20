# -*- encoding : utf-8 -*-

class MoreVotingCards < Card::Migration
  def up
    import_json 'voting.json'
  end
end
