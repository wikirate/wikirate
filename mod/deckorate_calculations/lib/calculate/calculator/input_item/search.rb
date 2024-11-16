class Calculate
  class Calculator
    class InputItem
      # private methods for finding relevant input records
      module Search
        def search result_space=nil
          @result_space = result_space || ResultSpace.new(false)
          @result_slice = ResultSlice.new
          full_search do |company_id, year, input_record|
            store_value company_id, year, input_record
          end
          after_search
        end

        # Find record for the given input card and cache the result.
        # If year is given look only for that year
        def full_search
          input_records_by_company_and_year.each do |company_id, input_record_hash|
            each_applicable_year(input_record_hash.keys) do |year|
              yield company_id, year, apply_year_option(input_record_hash, year)
            end
          end
        end

        def each_applicable_year raw_years, &block
          years = translate_years raw_years
          if search_space.years.present? && !restrict_years_in_query?
            years = years.intersection search_space.years
          end
          years.each(&block)
        end

        def search_space
          @search_space ||= result_space.record_candidates
        end

        def after_search
          result_space.update @result_slice, mandatory?
        end

        # Searches for all metric records for this metric input.
        def records
          ::Record.where record_query
        end

        def each_input_record rel, object
          rel.pluck(*INPUT_RECORD_FIELDS).each_with_object(object) do |fields, obj|
            company_id = fields.shift
            year = fields.shift
            input_record = InputRecord.new self, company_id, year
            input_record.assign(*fields)
            yield input_record, obj
          end
        end

        def search_company_ids
          ::Record.select(:company_id).distinct
                  .where(metric_id: input_card.id).pluck(:company_id)
        end

        def value_store
          @value_store ||= value_store_class.new
        end

        def store_value company_id, year, value
          value_store.add company_id, year, value
          update_result_slice company_id, year, value
        end

        def with_restricted_search_space company_id, year
          @search_space = SearchSpace.new company_id, year
          @search_space.intersect! result_space.record_candidates
          yield
        ensure
          @search_space = nil
        end

        def consolidated_input_record records, year
          lookup_ids = consolidate_lookup_ids records
          value = records.map(&:value)
          unpublished = records.find(&:unpublished)
          verification = records.map(&:verification).compact.min || 1
          InputRecord.new(self, nil, year)
                     .assign lookup_ids, value, unpublished, verification
        end

        def consolidate_lookup_ids records
          records.map { |a| a.try(:lookup_ids) || a.id }.flatten.uniq
        end
      end
    end
  end
end
