class Card
  class VegaChart
    class RangeChart
      # calculate the grouping for a range chart
      module Buckets
        def each_bucket
          lower = min
          # lower = log_bucket? ? 0 : min
          # real_lower = min
          @buckets.times do |i|
            upper = lower + bucket_size
            yield lower, upper, (i == @buckets)
            lower = upper
            # real_upper = real_bucket_size(upper)
            # yield real_lower, real_upper
            # real_lower = real_upper
          end
        end

        private

        # def real_# bucket_size size
        #   log_bucket? ? Math.exp(size).to_i + min : size
        # end

        # def log_bucket?
        #   false # TODO: restore functionality with toggle
        #   # return @use_log_scale unless @use_log_scale.nil?
        #   # @use_log_scale =
        #   #   if min >= 1
        #   #     max / min > 100
        #   #   else
        #   #     max > 200
        #   #   end
        # end

        def bucket_size
          @bucket_size ||= nice(raw_bucket_size) { |b| b * 1.05 }
        end

        def raw_bucket_size
          (max - min).to_f / @buckets
        end

        def max
          @max ||= limit_from_filter_args(:to) || limit_from_results(:maximum)
        end

        def raw_min
          @raw_min ||= limit_from_results(:minimum)
        end

        def limit_from_results method
          @filter_query.main_query.send(method, :numeric_value).to_f
        end

        def limit_from_filter_args dir
          value = @filter_query.filter_args[:value]
          return unless value.is_a? Hash
          value[dir].to_f
        end

        def min
          @min ||= limit_from_filter_args(:from) || auto_min
        end

        # if min not explicit, and lowest existing min is less than half of max,
        # use min of zero for graphing
        # (lean towards more zero-based graphs)
        def auto_min
          raw_min.positive? && raw_min < (max / 2.0) ? 0 : raw_min
        end

        # if the default bucket size is a roundish number, keep it.
        # If not, make it a bit bigger and round it.
        def nice num
          sig = sig num
          sig == num ? num : sig(yield(num))
        end

        def sig num
          # format hack to get spec working
          (@format || Card.new.format).number_with_precision(num, significant: true).to_f
        end
      end
    end
  end
end
