#! no set module

class ImportManager
  def initialize act_card: nil, conflict_strategy: :skip
    @act_card = act_card
    @conflict_strategy = conflict_strategy
    @errors = {}
  end

  def add_card args
    if @act_card
      @act_card.add_subcard args.delete(:name), args
    else
      pick_up_card_errors do
        Card.create args
      end
    end
  end

  def import_card card_args
    import_card = add_card card_args
    if import_card && @act_card
      import_card.director.catch_up_to_stage :validate
      import_card.director.transact_in_stage = :integrate
    end
    import_card
  end


  def add_report

  end

  def add_error index, msg, type = :invalid_data
    @errors[index] ||= []
    @errors[index] << msg
  end


  def save_failures
    act_card
  end

  def errors_by_row_index
    @errors.each do |index, msgs|
      yield index, msgs
    end
  end
end
