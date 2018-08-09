require('../../../../lib/javascript/script_metrics.js.coffee')

multiplier = 10**DIGITS_AFTER_DECIMAL

test 'return true if all values are equal', =>
  expect(variableValuesAreEqual([20,20,20,20,20])).toBeTruthy()

test 'return true if all are valid', =>
  hash = { one: '20', two: '20', three: '30', for: '20', five: '20' }
  expect(valuesAreValid(hash, multiplier).valid).toBeTruthy()

test 'return false if a value is not valid', =>
  hash = { one: '20', two: '20', three: '30', for: '20', five: '20.0000' }
  expect(valuesAreValid(hash, multiplier).valid).toBeFalsy()