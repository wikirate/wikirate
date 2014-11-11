# -*- encoding : utf-8 -*-

class ImportUndefinedTagAndClaimBoxAndNewClaimJsAndNewCompanyAndTopicBoxes < Wagn::Migration
  def up
          import_json "boxes.json"
      end
end
