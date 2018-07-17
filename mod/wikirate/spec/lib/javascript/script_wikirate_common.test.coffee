
require('../../../lib/javascript/script_wikirate_common.js.coffee')

test 'isString returns true for string', ->
  expect($.wikirate.isString("ab")).toBe true

test 'isString returns false for integer', ->
  expect($.wikirate.isString(5)).toBe false
