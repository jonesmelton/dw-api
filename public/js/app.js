document.body.addEventListener('htmx:afterSwap', function(evt) {
  document.getElementById("search-input").focus();
});
