# ValidateManager doesn't import anything. It is used for collecting invalid data
# to show it in the import table interface.
class ValidationManager < ImportManager
  def validate row_indices=nil, &block
    @after_validation = block
    validate_rows row_indices
  end

  def validate_rows row_indices
    row_count = row_indices ? row_indices.size : @csv_file.row_count
    @import_status = Status.new counts: { total: row_count }

    @csv_file.each_row self, row_indices do |csv_row|
      validate_row csv_row
    end
  end

  def validate_row csv_row
    handle_import csv_row do
      csv_row.prepare_import
    end
  end

  def add_card args
    handle_conflict args[:name], strategy: :skip_card do
      card = Card.new args
      card.validate
      pick_up_card_errors card
    end
  end

  def each_row
    @csv_file.each_row self do |row, i|
    end
  end

  def row_finished row
    @after_validation.call row
  end
end
