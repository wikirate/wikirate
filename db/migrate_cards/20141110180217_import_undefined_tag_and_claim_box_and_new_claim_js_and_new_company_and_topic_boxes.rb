# -*- encoding : utf-8 -*-

class ImportUndefinedTagAndClaimBoxAndNewClaimJsAndNewCompanyAndTopicBoxes < Wagn::Migration
  def up
          import_json "undefined_tag_and_claim_box_and_new_claim_js_and_new_company_and_topic_boxes.json"
      end
end
