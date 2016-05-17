# -*- encoding : utf-8 -*-

require File.expand_path("../../../lib/migration_helper", __FILE__)
include MigrationHelper

class RenameArticleToOverview < Card::Migration
  def up
    rename "article", "overview"
  end
end
