# -*- encoding : utf-8 -*-

class AddInverseTitleAndHelpText < Card::Migration
  def up
    ensure_card "inverse title", codename: "inverse_title"
    ensure_card "Relationship+description", type: :basic,
                content: "<p><strong>Relationship</strong> metrics evaluate connections between companies</p>"
    ensure_card "metric+inverse title+*type plus right+*help",
                content: "<p>How company B relates to company A, e.g. "\
                      "company B is <strong>owned by</strong> company A</p>"
    ensure_card "metric+inverse title+*type plus right+*default", type: :phrase

    ensure_card "Researched+description",
                content: "<p><strong>Standard</strong> metrics evaluate a single company directly</p>"
  end
end
