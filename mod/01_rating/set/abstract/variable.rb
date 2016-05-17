def to_variable_name index
  "M#{index}"
end

def variable_index name
  name.to_s =~ /^M?(\d+)$/
  Regexp.last_match(1).to_i
end

def variable_name? v_name
  v_name.to_s =~ /^M\d+$/
end
