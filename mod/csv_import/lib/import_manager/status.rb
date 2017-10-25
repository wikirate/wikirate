class ImportManager
  class Status < Hash
    require_dependency "import_manager/status/counts"

    # @param initial_status [Hash, Integer, String] a hash, a hash as json string or just
    #   the total number of imports
    def initialize status
      hash = normalize_init_args status
      counts = hash.delete(:counts)
      replace hash
      self[:counts] = Counts.new counts
      init_missing_values
    end

    def init_missing_values
      self[:errors] ||= Hash.new { |h, k| h[k] = [] }
      self[:reports] ||= Hash.new { |h, k| h[k] = [] }
      %i[imported skipped overridden failed].each do |n|
        self[n] ||= {}
      end
    end

    def normalize_init_args status
      sym_hash = case status
                 when Integer
                   { counts: { total: status } }
                 when String
                   JSON.parse status
                 when Hash
                   status
                 else
                   {}
                 end
      unstringify_keys sym_hash

    rescue JSON::ParserError => _e
      {}
    end

    def unstringify_keys hash
      hash.deep_symbolize_keys!
      hash.keys.each do |k|
        next if k == :counts || !hash[k].is_a?(Hash)
        hash[k] = hash[k].inject({}) do |options, (key, value)|
          options[(Integer(key.to_s) rescue key)] = value
          options
        end
      end
      hash
    end
  end
end
