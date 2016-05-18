# -*- encoding : utf-8 -*-

require File.expand_path("../../../lib/migration_helper", __FILE__)
include MigrationHelper

class RenameClaimToNote < Card::Migration
  def up
    rename "claim", "note"
  end
end
