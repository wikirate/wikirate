# ActImportManager puts all creates and update actions that are part of the import
# under one act of a import card
class ActImportManager < ImportManager
  def initialize act_card, csv_file, conflict_strategy=:skip, extra_row_data={}
    @act_card = act_card
    super(csv_file, conflict_strategy, extra_row_data)
  end

  def add_card args
    handle_conflict args[:name] do |existing_card|
      subcard =
        if existing_card
          existing_card.tap { |card| card.update_attributes args }
        else
          Card.create args
        end
      # subcard = @act_card&.add_subcard args.delete(:name), args
      # subcard.director.catch_up_to_stage :validate
      pick_up_card_errors { subcard }
    end
  end

  def duplicate name
    Card[name] || @act_card&.subcards&.at(name)
  end

  def log_status
    super
    @act_card&.import_status_card&.update_attributes content: @import_status.to_json
  end

  private

  def init_import_status row_count=nil
    isc = @act_card&.try :import_status_card
    @import_status = isc&.real? ? isc.status : super
  end

  def row_finished row
    return if row.status == :failed
    @act_card&.mark_as_imported row.row_index
  end
end
