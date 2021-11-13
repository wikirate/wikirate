Card::ImportLog.logger = Logger.new(Card::ImportLog::LogFile)
Card::ImportLog.logger.level = "debug"
