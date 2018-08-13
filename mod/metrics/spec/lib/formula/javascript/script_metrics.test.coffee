CARD_MOD_DIR = "../../../../../../vendor/decko/card/mod/";
DECKO_JS_DIR = CARD_MOD_DIR + "/machines/lib/javascript/";

# commenting for now, because export is not working outside of Jest
# (presumably because it's a Nod

# require( DECKO_JS_DIR  +  'decko_editor.js.coffee' );
# $.extend global, require('../../../../lib/javascript/script_metrics.js.coffee')
#
# multiplier = 10**DIGITS_AFTER_DECIMAL
#
# test 'return true if all values are equal', =>
#   expect(variableValuesAreEqual([20,20,20,20,20])).toBeTruthy()
#
# test 'return true if all are valid', =>
#   hash = { one: '20', two: '20', three: '30', for: '20', five: '20' }
#   expect(valuesAreValid(hash, multiplier).valid).toBeTruthy()
#
# test 'return false if a value is not valid', =>
#   hash = { one: '20', two: '20', three: '30', for: '20', five: '20.0000' }
#   expect(valuesAreValid(hash, multiplier).valid).toBeFalsy()