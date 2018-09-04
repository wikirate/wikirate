$.extend global, require('../../../../lib/javascript/script_value_type.js.coffee')

test 'return true if it returns an array with the properties corresponding to "Number" and "Money"', =>
  expect(getPropertiesValueType('Number')).toEqual(['Unit','Range'])
  expect(getPropertiesValueType('Money')).toEqual(['Unit','Range'])

test 'return true if it returns an array with the properties corresponding to "Category" and "Multi-Category"', =>
  expect(getPropertiesValueType('Category')).toEqual(['Options'])
  expect(getPropertiesValueType('Multi-Category')).toEqual(['Options'])