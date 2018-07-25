
require('../../../lib/javascript/script_wikirate_common.js.coffee')

#isMaxDigit = (num) -> 
  #aux = true 
  #val = num.split('.')
  #aux = false if val.length > 1 && val[1].length > 2 
  #return aux; 


test 'isString returns true for string', =>
  expect($.wikirate.isString("ab")).toBeTruthy()

test 'isString returns false for integer', =>
  expect($.wikirate.isString(5)).toBeFalsy()

#test 'isMaxDigit return false if a string contains more than two characters after the "."', => 
  #expect(isMaxDigit('22.111')).toBeFalsy()

#test 'isMaxDigit return true if a string contains less or two characters after the "."', => 
  #expect(isMaxDigit('22.11')).toBeTruthy()
