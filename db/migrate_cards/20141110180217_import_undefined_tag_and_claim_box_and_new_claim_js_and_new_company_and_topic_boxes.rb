# -*- encoding : utf-8 -*-

class ImportUndefinedTagAndClaimBoxAndNewClaimJsAndNewCompanyAndTopicBoxes < Card::Migration
  def up
          import_json "boxes.json"
      end
end
