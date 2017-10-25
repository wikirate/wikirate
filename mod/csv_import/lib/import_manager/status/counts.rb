class ImportManager
  class Status
    class Counts < Hash
      def initialize hash
        hash ||= {}
        replace hash
      end

      def default key
        0
      end

      def count key
        if key.is_a? Array
          key.inject(0) { |sum, k| sum + self[k] }
        else
          self[key]
        end
      end

      def step key
        self[key] += 1
      end

      def percentage key
        return 0 if count(:total) == 0 || count(key).nil?
        (count(key) / count(:total).to_f * 100).floor(2)
      end
    end
  end
end
