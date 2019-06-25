document.addEventListener('DOMContentLoaded', function() {
  var sidenav = document.getElementById("slide-out");
  var searchModal = document.getElementById("search-modal");

  // initialize sidenav
  M.Sidenav.init(sidenav);
  window.sidenav = M.Sidenav.getInstance(sidenav);

  // initialize search modal
  M.Modal.init(searchModal, {
    onOpenEnd: function() {
      // focus on input when modal is launched
      document.getElementById("album-search-input").focus();
  }});
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

// ====== START SEARCH MODAL ======
function stringToNode(html) {
  const template = document.createElement('template');
  template.innerHTML = html;
  return template.content.firstChild;
}

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

const searchSpinner = document.getElementById("search-spinner-container");
function hideSearchSpinner() {
  if (searchSpinner.classList.contains("hide")) return;
  searchSpinner.classList.add("hide");
}

function showSearchSpinner() {
  searchSpinner.classList.remove("hide");
}

document.getElementById("album-search-input").addEventListener("keydown", function(e) {
  if(e.keyCode == 13) {
    removeSelectedElement(".search-album");
    // display results inline with side-scroll
    document.getElementById("search-results").style.display = "inline-flex";
    removeSelectedElement("#search-result-warning");
    showSearchSpinner();

    var search = document.getElementById("album-search-input").value.trim();
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        displaySearchResults(JSON.parse(xhr.responseText));
      } else {
        hideSearchSpinner();
        console.log('error', xhr);
      }
    };
    xhr.open("GET", `/api/apple/search/?search_string=${search}&offset=0`);
    xhr.send();
  }
});

function displaySearchResults(results) {
  const searchResultsContainer = document.getElementById("search-results");

  if (results.albums.length < 1) {
    hideSearchSpinner();
    searchResultsContainer.appendChild(stringToNode(
      `<div id="search-result-warning" class="center-align">
        <em class="grey-text text-darken-1">
          No albums match your search! Try another artist or album.
        </em>
      </div>`
    ));
    // required for warning element to display centered
    return document.getElementById("search-results").style.display = "block";
  }

  hideSearchSpinner();
  // display results inline with side-scroll
  document.getElementById("search-results").style.display = "inline-flex";
  for (let i = 0; i < results.albums.length; i++) {
    const album = results.albums[i];
    const albumCover = album.cover.replace("{w}", "230").replace("{h}", "230");
    searchResultsContainer.appendChild(stringToNode(
      `<div class="search-album" onclick="window.open('/albums/${album.appleAlbumID}', '_self')">
        <img class="search-album-cover" src="${albumCover}">
        <p class="search-title">${album.title}</p>
        <p class="search-artist grey-text text-darken-1">${album.artist}</p>
      </div>`
    ));
  }
}

document.getElementById("clear-album-search-input-btn").addEventListener("click", function(e) {
  var searchInput = document.getElementById("album-search-input");
  searchInput.value = "";
  searchInput.focus();
});
// ====== END SEARCH MODAL ======
