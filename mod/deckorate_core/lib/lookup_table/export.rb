module LookupTable
  module Export
    def with_detailed basic, detailed=false
      detailed ? (basic + yield) : basic
    end
  end
end
