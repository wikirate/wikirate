# -*- encoding : utf-8 -*-

class ImportVotingPatch < Wagn::Migration
  def up
    import_json "voting_patch.json"
  end
end
