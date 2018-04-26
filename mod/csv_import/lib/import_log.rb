class ImportLog
  LogFile = Rails.root.join("log", "import.log")
  class << self
    cattr_accessor :logger
    delegate :debug, :info, :warn, :error, :fatal, to: :logger
  end
end
