def to_variable_name index
  "M#{index}"
end

def variable_index name
  return name if name.is_a? Integer
  name.to_s =~ /^M?(\d+)$/
  Regexp.last_match(1).to_i
end

def variable_name? v_name
  v_name.to_s =~ /^M\d+$/
end
