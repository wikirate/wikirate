class Hash
  class << self
    def new_nested *structure
      initialize_nested structure.unshift Hash
    end

    def initialize_nested classes
      klass = classes.shift
      if classes.empty?
        klass.new
      else
        klass.new do |h, k|
          h[k] = initialize_nested classes
        end
      end
    end
  end
end