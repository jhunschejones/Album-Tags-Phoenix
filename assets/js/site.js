document.addEventListener('DOMContentLoaded', function() {
  var sidenav = document.getElementById("slide-out");
  var searchModal = document.getElementById("search-modal");

  // initialize sidenav
  M.Sidenav.init(sidenav);
  window.sidenav = M.Sidenav.getInstance(sidenav);

  // initialize search modal
  M.Modal.init(searchModal);
  window.searchModal = M.Modal.getInstance(sidenav);

  // open sidenav on menu button click
  document.getElementById("open-sidenav").addEventListener("click", function(e) {
    e.preventDefault();
    window.sidenav.open();
  });

  // close sidenav when search modal is opened
  document.getElementById("open-search-modal").addEventListener("click", function(e) {
    window.sidenav.close();
  });
});
