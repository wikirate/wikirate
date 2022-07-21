module LookupTable
  # support methods for exporting from lookup tables
  module Export
    def with_detailed basic, detailed=false
      detailed ? (basic + yield) : basic
    end
  end
end
