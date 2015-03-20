# -*- encoding : utf-8 -*-

class ImportVotingPatch < Card::Migration
  def up
    import_json "voting_patch.json"
  end
end
