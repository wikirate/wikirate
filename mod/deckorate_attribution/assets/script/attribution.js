$(document).ready(function() {
  $(".copy-button").click(function() {
    var clipboardContent = $("#clipboard").text();
    
    navigator.clipboard.writeText(clipboardContent)
      .then(function() {
        console.log("Text copied to clipboard: " + clipboardContent);
      })
      .catch(function(error) {
        console.error("Copy to clipboard failed:", error);
      });
  });
});