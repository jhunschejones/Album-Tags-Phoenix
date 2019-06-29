document.addEventListener('DOMContentLoaded', function() {
  var elems = document.querySelectorAll('.parallax');
  var instances = M.Parallax.init(elems, {});
});

document.getElementsByClassName("open-search-menu")[0].addEventListener("click", function(e) {
  e.preventDefault();
  window.sidenav.open();
});
