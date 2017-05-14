# -*- encoding : utf-8 -*-

class CompanyProjectSearch < Card::Migration
  def up
    #ensure_card [:wikirate_company, :project, :type_plus_right, :default], type_id: Card::SearchTypeID
    ensure_card [:wikirate_company, :project, :type_plus_right, :structure],
                type_id: Card::SearchTypeID,
                content:
                    <<-JSON
                  {
                      "type":"Project",
                      "right_plus": ["Company", {"refer_to":"_left"}]
                  }
    JSON
    ensure_card "Projects Organized", codename: "projects_organized"
    ensure_card "Metrics Designed", codename: "metrics_designed"
    Card::Cache.reset_all
    ensure_card [:wikirate_company, :projects_organized, :type_plus_right, :structure],
                type_id: Card::SearchTypeID,
                content:
                    <<-JSON
                   { "type": "Project",
                     "right_plus": ["organizer", { "refer_to": "_left" }]}
    JSON
    ensure_card [:wikirate_company, :metrics_designed, :type_plus_right, :structure],
                type_id: Card::SearchTypeID,
                content: '{ "type": "Metric", "left": "_left" }'
  end
end
