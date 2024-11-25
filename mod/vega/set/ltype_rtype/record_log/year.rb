# FIXME: This should be much easier and cleaner
#
# All we want to do is set the default type to be metric answer. This could be
# done in cards with `Record+Year+*ltype rtype+*default`, but there's no
# easy way to do it in code.
#
# The reason this is done in the vega mod is that this mod alters Type::Answer.
# If you call `include_set Type::Answer` in a mod that is loaded earlier, you
# will not get the vega alterations.  sigh.
#
# So this is actually TWO todos:
#
# 1. review set load order.  Definitely need to load all abstract sets before loading
#   any anchored ones  (this should be fixed -efm)

# 2. there neds to be a simple coded way to set a default type. (probably new api for
#    Card::Rule)

def default_type_id
  AnswerID
end

include_set Type::Answer

def type_id
  AnswerID
end
