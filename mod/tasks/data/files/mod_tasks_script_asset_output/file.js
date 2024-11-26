// task_bar.js.coffee
(function() {
  var openBar;

  openBar = function(bar) {
    var path;
    path = bar.slot().data("card-link-name");
    return window.open(decko.path(path));
  };

  $(document).ready(function() {
    $('body').on('click', '.bar.TYPE-task', function() {
      return openBar($(this));
    });
    return $('body').on('click', '.bar.TYPE-task a', function() {
      openBar($(this).closest('.bar'));
      return false;
    });
  });

}).call(this);
