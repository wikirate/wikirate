def import_act?
  ActManager.act_card&.import_file?
end

# for override
def import_file?
  false
end
