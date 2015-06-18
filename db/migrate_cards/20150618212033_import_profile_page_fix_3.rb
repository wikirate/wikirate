# -*- encoding : utf-8 -*-

class ImportProfilePageFix3 < Card::Migration
  def up
    import_json "profile_page_fix_3.json"
    metric_designer_with_wrong_cardtype = {"not"=>{"type"=>["in", "company", "user"]}, "right_plus"=>[{}, {"type"=>"metric"}]}
    Card.search(metric_designer_with_wrong_cardtype).each do |card|
      card.update_attributes! :type_id=>Card::WikirateCompanyID
    end
  end
end
