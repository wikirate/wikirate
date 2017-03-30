class Card
  module Chart
    class RangeChart
      # calculate the grouping for a range chart
      module Buckets
        def each_bucket
          lower = log_bucket? ? Math.log(min) : min
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
            log_min = min == 0 ? 0 : Math.log(min)
            exp_range = Math.log(max - min) - log_min
            @bucket_size = exp_range / @buckets
          else
            round_bucket_size
          end
        end

        private

        def real_bucket_size size
          log_bucket? ? Math.exp(size) : size
        end

        def log_bucket?
          return false if min < 0
          # FIXME: not a reasonable condition for using log
          @use_log = bucket_size > 1000 if @use_log.nil?
          @use_log
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
