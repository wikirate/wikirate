# -*- encoding : utf-8 -*-

class MoreVotingCards < Wagn::Migration
  def up
    import 'voting.json'
  end
end
