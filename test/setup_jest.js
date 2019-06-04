CARD_MOD_DIR = "../vendor/decko/card/mod/";
DECKO_JS_DIR = CARD_MOD_DIR + "/machines/lib/javascript/decko/";
JQUERY_DIR = CARD_MOD_DIR + "machines/vendor/jquery_rails/vendor/assets/javascripts/";

global.$ = global.jQuery = window.$ = require(JQUERY_DIR + "jquery3.js");
require(JQUERY_DIR + "jquery_ujs.js");


const filenames = [
    "mod", "editor", "name_editor", "autosave", "doubleclick", "layout", "navbox",
    "upload", "slot", "modal", "overlay", "recaptcha", "slotter", "bridge",
    "nest_editor", "nest_editor_rules", "nest_editor_options", "nest_editor_name",
    "components", "decko", "follow", "card_menu", "slot_ready", "filter", "filter_items"
];

filenames.forEach(filename => {
    require(DECKO_JS_DIR + filename + ".js.coffee");
});
