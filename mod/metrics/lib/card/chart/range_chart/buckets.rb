class Card
  module Chart
    class RangeChart
      # calculate the grouping for a range chart
      module Buckets
        def each_bucket
          lower = log_bucket? ? 0 : min
          real_lower = min
          @buckets.times do
            upper = lower + bucket_size
            real_upper = real_bucket_size(upper)
            yield real_lower, real_upper
            lower = upper
            real_lower = real_upper
          end
        end

        def calculate_buckets
          return unless bucket_size > 2
          if log_bucket?
            @bucket_size = Math.log(max * 1.000001 - min) / @buckets
          else
            round_bucket_size
          end
        end

        private

        def real_bucket_size size
          log_bucket? ? Math.exp(size).to_i + min : size
        end

        def log_bucket?
          return @use_log_scale unless @use_log_scale.nil?
          @use_log_scale =
            if min >= 1
              max / min > 100
            else
              max > 200
            end
        end

        def round_bucket_size
          @bucket_size = (@bucket_size + 1).to_i
          @min = @min.to_i
          @max = @min + @bucket_size * @buckets
        end

        def bucket_size
          @bucket_size ||= (max - min).to_f / @buckets
        end

        def max
          @max ||= @filter_query.where.maximum(:numeric_value).to_f
        end

        def min
          @min ||= @filter_query.where.minimum(:numeric_value).to_f
        end
      end
    end
  end
end
