assign_type :pointer

def virtual?
  new?
end

def content
  new? ? "CC BY 4.0" : super
end
