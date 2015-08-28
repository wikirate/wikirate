# -*- encoding : utf-8 -*-
require File.expand_path('../../../lib/migration_helper', __FILE__)
include MigrationHelper

class RenameCampaignToInitiative < Card::Migration
  def up
    rename_card 'campaign', 'overview'
  end
end
