attr_accessor :auto_content

def ok_to_update
  auto_content or super
end