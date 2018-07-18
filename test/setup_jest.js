CARD_MOD_DIR = "../vendor/decko/card/mod/";
DECKO_JS_DIR = CARD_MOD_DIR + "/machines/lib/javascript/";

global.$ = global.jQuery = window.$ =
    require(CARD_MOD_DIR + "machines/vendor/jquery_rails/vendor/assets/javascripts/jquery3.js");
require(CARD_MOD_DIR + 'machines/vendor/jquery_rails/vendor/assets/javascripts/jquery_ujs.js');
require(DECKO_JS_DIR + 'decko_mod.js.coffee');
require(DECKO_JS_DIR + 'decko_slot.js.coffee');
require(DECKO_JS_DIR + 'decko.js.coffee');
