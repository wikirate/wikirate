# -*- encoding : utf-8 -*-

class ConvertDelayedJobTableToUtf8 < Card::Migration
  def up
    execute("ALTER TABLE delayed_jobs CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;")
  end
end
