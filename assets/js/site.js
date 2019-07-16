var albumTags = {
  initializeSidenav: function() {
    var sidenavElement = document.getElementById("slide-out");
    M.Sidenav.init(sidenavElement);
    albumTags.sidenav = M.Sidenav.getInstance(sidenavElement);
  },
  initializeSearchModal: function() {
    var searchModalElement = document.getElementById("search-modal");

    M.Modal.init(searchModalElement, {
      onOpenEnd: function() {
        albumTags.albumSearchInput.focus();
    }});
    albumTags.searchModal = M.Modal.getInstance(searchModalElement);
  },
  hideSearchSpinner: function() {
    if (!albumTags.searchSpinner.classList.contains("hide")) {
      albumTags.searchSpinner.classList.add("hide");
    }
  },
  showSearchSpinner: function() {
    albumTags.searchSpinner.classList.remove("hide");
  },
  executeAlbumSearch: function() {
    removeSelectedElement(".search-album");
    // display album search results inline with side-scroll
    document.getElementById("search-results").style.display = "inline-flex";
    removeSelectedElement("#search-result-warning");
    albumTags.showSearchSpinner();

    var search = albumTags.albumSearchInput.value.trim();
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        albumTags.displaySearchResults(JSON.parse(xhr.responseText));
      } else {
        albumTags.hideSearchSpinner();
        console.log('error', xhr);
      }
    };
    xhr.open("GET", `/api/apple/search/?search_string=${search}&offset=0`);
    xhr.send();
  },
  displaySearchResults: function(results) {
    albumTags.searchResultsContainer = document.getElementById("search-results");

    if (results.albums.length < 1) {
      return albumTags.showNoResultsWarning();
    }

    albumTags.hideSearchSpinner();
    // display album results inline with side-scroll
    document.getElementById("search-results").style.display = "inline-flex";

    for (let i = 0; i < results.albums.length; i++) {
      const album = results.albums[i];
      const albumCover = album.cover.replace("{w}", "230").replace("{h}", "230");
      albumTags.searchResultsContainer.appendChild(stringToNode(
        `<div class="search-album" onclick="window.open('/albums/${album.appleAlbumID}', '_self')">
          <img class="search-album-cover" src="${albumCover}">
          <p class="search-title">${album.title}</p>
          <p class="search-artist grey-text text-darken-1">${album.artist}</p>
        </div>`
      ));
    }
  },
  showNoResultsWarning: function() {
    albumTags.hideSearchSpinner();
    albumTags.searchResultsContainer.appendChild(stringToNode(
      `<div id="search-result-warning" class="center-align">
        <em class="grey-text text-darken-1">
          No albums match your search! Try another artist or album.
        </em>
      </div>`
    ));
    // required styling to display warning element centered
    document.getElementById("search-results").style.display = "block";
  }
};

document.addEventListener('DOMContentLoaded', function() {
  var menuHambergerBtn = document.getElementById("open-sidenav");
  var searchBtn = document.getElementById("open-search-modal");
  albumTags.albumSearchInput = document.getElementById("album-search-input");
  albumTags.searchSpinner = document.getElementById("search-spinner-container");
  albumTags.clearAlbumSearchInputBtn = document.getElementById("clear-album-search-input-btn");

  albumTags.initializeSidenav();
  albumTags.initializeSearchModal();

  menuHambergerBtn.addEventListener("click", function(e) {
    e.preventDefault();
    albumTags.sidenav.open();
  });
  searchBtn.addEventListener("click", function() {
    // close sidenav when search modal is opened
    albumTags.sidenav.close();
  }, {passive: true});
  albumTags.albumSearchInput.addEventListener("keydown", function(e) {
    if(e.keyCode == 13) {
      albumTags.executeAlbumSearch();
    }
  }, {passive: true});
  albumTags.clearAlbumSearchInputBtn.addEventListener("click", function() {
    albumTags.albumSearchInput.value = "";
    albumTags.albumSearchInput.focus();
  });
});

// ====== START UTILITIES ======
/**
 * Convert an HTML string into a DOM node to append to the page
 * @param  {string} html html to convert into a DOM node
 */
function stringToNode(html) {
  const template = document.createElement('template');
  template.innerHTML = html;
  return template.content.firstChild;
}

/**
 * Remove an element from the DOM by class or id selector
 * @param  {string} selector element selector to remove, i.e. `.tags` or `#spinner`
 */
function removeSelectedElement(selector) {
  if (selector[0] === ".") {
    const c = document.querySelectorAll(selector);
    for (let i = 0; i < c.length; i++) {
      c[i].parentNode.removeChild(c[i]);
    }
  } else if (selector[0] === "#") {
    const e = document.getElementById(selector.substring(1));
    if (e) { e.parentNode.removeChild(e); }
  } else {
    console.error("removeSelectedElement() was passed an invalid selector");
  }
}
// ====== END UTILITIES ======
