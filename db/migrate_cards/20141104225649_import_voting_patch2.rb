# -*- encoding : utf-8 -*-

class ImportVotingPatch2 < Card::Migration
  def up
          import_json "voting_patch2.json"
      end
end
