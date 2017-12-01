class ImportManager
  # Methods to deal with conflicts with existing cards
  module Conflicts
    def override?
      @conflict_strategy == :override
    end

    def check_for_duplicates name
      key = name.to_name.key
      if @imported_keys.include? key
        report :duplicate_in_file, name
        throw :skip_row, :skipped
      else
        @imported_keys << key
      end
    end

    def with_conflict_strategy strategy
      tmp_cs = @conflict_strategy
      @conflict_strategy = strategy if strategy
      yield
    ensure
      @conflict_strategy = tmp_cs
    end

    def handle_conflict name, strategy: nil
      with_conflict_strategy strategy do
        with_conflict_resolution name do
          yield
        end
      end
    end

    def with_conflict_resolution name
      return yield unless (@dup = duplicate(name))

      case @conflict_strategy
      when :skip      then throw :skip_row, :skipped
      when :skip_card then @dup
      else
        @status = :overridden
        yield
      end
    end

    def duplicate name
      Card[name]
    end
  end
end
