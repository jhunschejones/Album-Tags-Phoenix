(function() {
  document.addEventListener('DOMContentLoaded', function() {
    var elems = document.querySelectorAll('.parallax');
    var instances = M.Parallax.init(elems, {});

    var openSearchModalLink = document.getElementsByClassName("open-search-menu")[0];
    openSearchModalLink.addEventListener("click", function(e) {
      e.preventDefault();
      albumTags.searchModal.open();
    });
  }, {passive: true});
})();
