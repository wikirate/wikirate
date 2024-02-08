const { defineConfig } = require('cypress')

module.exports = defineConfig({
  projectId: 'aauu9f',
  defaultCommandTimeout: 10000,
  watchForFileChanges: false,
  e2e: {
    // We've imported your old cypress plugins here.
    // You may want to clean this up later by importing these.
    setupNodeEvents(on, config) {
      return require('./vendor/decko/decko/spec/cypress/plugins/index.js')(on, config)
    },
    baseUrl: 'http://localhost:5002',
    specPattern: 'mod/*/cypress/**/*spec.coffee',
    supportFile: 'vendor/decko/decko/spec/cypress/support/e2e.js',
  },
})
