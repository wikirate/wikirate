#! no set module

class ErrorHandler
  def initialize format, conflict_strategy: :skip
    @format = format
    @conflict_strategy = conflict_strategy
  end

  def add_report

  end

  def add_error index, msg, type: :invalid_data

  end

  def alert

  end

  def save_failures

  end
end
