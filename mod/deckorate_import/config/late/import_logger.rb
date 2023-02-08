Card::ImportLog.logger = Logger.new(Card::ImportLog::LOG_FILE)
Card::ImportLog.logger.level = "debug"
