class ImportManager
  # Methods to collect errors and report the status of the import
  module StatusLog
    def log_status
      import_status[@current_row.status] ||= {}
      import_status[@current_row.status][@current_row.row_index] = @current_row.name
      import_status[:counts].step @current_row.status
    end

    def report key, msg
      case key
      when :duplicate_in_file
        msg = "#{msg} duplicate in this file"
      end
      import_status[:reports][@current_row.row_index] ||= []
      import_status[:reports][@current_row.row_index] << msg
    end

    def import_status
      @import_status || init_import_status
    end

    # used by {CSVRow} objects
    def report_error msg
      import_status[:errors][@current_row.row_index] ||= []
      import_status[:errors][@current_row.row_index] << msg
    end

    def errors_by_row_index
      @import_status[:errors].each do |index, msgs|
        yield index, msgs
      end
    end

    def pick_up_card_errors card=nil
      card = yield if block_given?
      if card
        card.errors.each do |error_key, msg|
          report_error "#{card.name} (#{error_key}): #{msg}"
        end
        card.errors.clear
      end
      card
    end

    def errors? row=nil
      if row
        errors(row).present?
      else
        errors.values.flatten.present?
      end
    end

    def errors row=nil
      if row
        import_status.dig(:errors, row.row_index) || []
      else
        import_status[:errors] || {}
      end
    end

    def error_list
      @import_status[:errors].each_with_object([]) do |(index, errors), list|
        next if errors.empty?
        list << "##{index + 1}: #{errors.join('; ')}"
      end
    end

    private

    def init_import_status row_count=nil
      @import_status = ImportManager::Status.new(row_count || 0)
    end

    def specify_success_status status
      return status if status.in? %i[failed skipped]
      @status == :overridden ? :overridden : :imported
    end
  end
end
