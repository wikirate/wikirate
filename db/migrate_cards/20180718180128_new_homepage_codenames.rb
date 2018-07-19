# -*- encoding : utf-8 -*-

class NewHomepageCodenames < Card::Migration
  def up
    ensure_card "homepage numbers", codename: "homepage_numbers"
    ensure_card "homepage projects", codename: "homepage_projects"
    ensure_card "homepage topics", codename: "homepage_topics"
    ensure_card "homepage organizations", codename: "homepage_organizations"
    ensure_card "homepage video section", codename: "homepage_video_section"
    ensure_card "homepage footer", codename: "homepage_footer"
    Card::Cache.reset_all
  end
end
