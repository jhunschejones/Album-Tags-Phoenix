// ====== START VUE APP ======
var listVueApp = new Vue({
  el: '#listVueApp',
  data: {
    albums: allAlbums,
    selectedAlbums: [],
    listUserID: listUserID,
    yearFilters: [],
    artistFilters: [],
    tagFilters: [],
    listTitle: listTitle,
    titleTags: tagSearchTags
  },
  methods: {
    albumCover: function(album, size) {
      return album.cover.replace("{w}", size).replace("{h}", size);
    },
    removeAlbum: function(albumID) { removeAlbumFromList(albumID); },
    resetSelectedAlbums: function() {
      var albums = JSON.parse(JSON.stringify(this.albums));
      // filter tags down to just those made by the list creator if this is a user list
      if (listUserID) {
        for (var i = 0; i < albums.length; i++) {
          var album = albums[i];
          album.tags = album.tags.filter(t => t.user_id == this.listUserID);
        }
      }
      this.selectedAlbums = albums;
    }
  },
  computed: {
    selectedAlbumsCount: function () { return this.selectedAlbums.length; },
    artists: function() {
      return Array.from(new Set(
        this.selectedAlbums.slice().map(a => a.artist)
      ));
    },
    years: function() {
      return Array.from(new Set(
        this.selectedAlbums.slice().map(a => a.release_date.substr(0,4))
      ));
    },
    tags: function() {
      return Array.from(new Set(this.selectedAlbums.slice().map(a =>
        a.tags.map(t => t.text)).flat()
      ));
    },
    allFilters: function() {
      return this.yearFilters.concat(this.artistFilters).concat(this.tagFilters);
    }
  },
  watch: {
    albums: function () {
      this.resetSelectedAlbums();
    },
    yearFilters: function(updatedValue) {
      setURIparams("years", updatedValue);
    },
    tagFilters: function(updatedValue) {
      setURIparams("tags", updatedValue);
    },
    artistFilters: function(updatedValue) {
      setURIparams("artists", updatedValue);
    }
  },
  beforeMount() {
    this.resetSelectedAlbums();
  },
  mounted() {
    // remove static list title for progressive enhancement
    const e = document.getElementById("htm-title");
    e.parentNode.removeChild(e);

    // set filters
    this.artistFilters = getURIparam("artists");
    this.yearFilters = getURIparam("years");
    this.tagFilters = getURIparam("tags");

    // vue app methods and data are not fully availible to external functions
    // until everything is fully loaded in the DOM
    document.addEventListener('DOMContentLoaded', filterAll);
  }
});

// ====== END VUE APP ======
// ====== START MATERIALIZE ======
document.addEventListener('DOMContentLoaded', function() {
  var editableList = document.getElementById("remove-album");
  if (editableList) {
    // initialize edit and add album modals
    var editListModal = document.getElementById("edit-list-modal");
    window.editListModal = M.Modal.init(editListModal, {
      onOpenEnd: function() {
        // focus on input when modal is launched
        var input = document.getElementById("list-name-input");
        input.focus();
        // move cursor to end of input field
        input.selectionStart = input.selectionEnd = input.value.length;
    }});

    document.getElementById("edit-list").addEventListener("click", function() {
      window.editListModal.open();
    });

    document.getElementById("clear-list-name-input-btn").addEventListener("click", function(e) {
      var searchInput = document.getElementById("list-name-input");
      searchInput.value = "";
      searchInput.focus();
    });

    var addAlbumModal = document.getElementById("add-album-modal");
    window.addAlbumModal = M.Modal.init(addAlbumModal, {
      onOpenEnd: function() {
        // focus on input when modal is launched
        var input = document.getElementById("add-album-input");
        input.focus();
    }});

    document.getElementById("add-album").addEventListener("click", function() {
      window.addAlbumModal.open();
    });

    document.getElementById("clear-add-album-input-btn").addEventListener("click", function(e) {
      var searchInput = document.getElementById("add-album-input");
      searchInput.value = "";
      searchInput.focus();
    });
  }
});

document.addEventListener('DOMContentLoaded', function() {
  // close toasts on click
  document.addEventListener("click", function(e) {
    var parent = e.target.parentNode
    var isToast = (parent && parent.classList && parent.classList.contains("toast")) || (parent && parent.id == "toast-container");
    if (isToast) return closeToast();
  });

  function closeToast() {
    var toastElement = document.querySelector('.toast');
    var toastInstance = M.Toast.getInstance(toastElement);
    toastInstance.dismiss();
  }

  // initialize main floating action button
  var mainBtn = document.getElementById("lists-fab-button");
  var mainBtnFab = M.FloatingActionButton.init(mainBtn, {
    direction: "top",
    hoverEnabled: false
  });

  // close expanded fabs when user clicks somewhere not on the buttons
  document.addEventListener("click", function(e) {
    if (!e.target.parentNode) return;
    var clickedMainFAB = [
      "show-buttons", "add-lists", "edit-lists", "remove-album", "filter-fab"
    ].includes(e.target.parentNode.id);

    if (!clickedMainFAB) mainBtnFab.close();
  }, {passive: true});

  document.getElementById("show-filters").addEventListener("click", function() {
    setTimeout(() => {
      document.getElementById("bottom-filters").classList.remove("hide");
    }, 150);
  }, {passive: true});

  document.getElementById("clear-all-filters").addEventListener("click", function() {
    listVueApp.yearFilters = [];
    listVueApp.artistFilters = [];
    listVueApp.tagFilters = [];
    listVueApp.resetSelectedAlbums();
    filterAll();

    hilightSelectedArtistFilters();
    hilightSelectedTagFilters();
    hilightSelectedYearFilters();
    document.getElementById("bottom-filters").classList.add("hide");
    M.toast({html: "All filters cleared", displayLength: 2500});
  }, {passive: true});

  document.getElementById("close-filter-menu").addEventListener("click", function() {
    document.getElementById("bottom-filters").classList.add("hide");
  }, {passive: true});

  document.addEventListener("scroll", function() {
    setTimeout(() => {
      document.getElementById("bottom-filters").classList.add("hide");
    }, 50);
  }, {passive: true});

  // initialize year filter modal
  var yearFilterModal = document.getElementById("year-filter-modal");
  window.yearFilterModal = M.Modal.init(yearFilterModal, {
    onCloseStart: function() {
      // execute filter on modal close in case user forgets to click button
      listVueApp.resetSelectedAlbums();
      filterAll();
    }
  });

  document.getElementById("year-filter-btn").addEventListener("click", function() {
    hilightSelectedYearFilters();
    window.yearFilterModal.open();
  });

  // initialize artist filter modal
  var artistFilterModal = document.getElementById("artist-filter-modal");
  window.artistFilterModal = M.Modal.init(artistFilterModal, {
    onCloseStart: function() {
      // execute filter on modal close in case user forgets to click button
      listVueApp.resetSelectedAlbums();
      filterAll();
    }
  });

  document.getElementById("artist-filter-btn").addEventListener("click", function() {
    hilightSelectedArtistFilters();
    window.artistFilterModal.open();
  });

  // initialize tag filter modal
  var tagFilterModal = document.getElementById("tag-filter-modal");
  window.tagFilterModal = M.Modal.init(tagFilterModal, {
    onCloseStart: function() {
      // execute filter on modal close in case user forgets to click button
      listVueApp.resetSelectedAlbums();
      filterAll();
    }
  });

  document.getElementById("tag-filter-btn").addEventListener("click", function() {
    hilightSelectedTagFilters();
    window.tagFilterModal.open();
  });
});
// ====== END MATERIALIZE ======

// ====== START UTILITIES ======
function showClass(className) {
  var elems = document.getElementsByClassName(className);
  for (var i = 0; i < elems.length; i++) {
    elems[i].classList.remove("hide");
  }
}

function hideClass(className) {
  var elems = document.getElementsByClassName(className);
  for (var i = 0; i < elems.length; i++) {
    elems[i].classList.add("hide");
  }
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

function stringToNode(html) {
  const template = document.createElement('template');
  template.innerHTML = html;
  return template.content.firstChild;
}

/**
 * addEventListenerToClass - description
 * @param  {string} class class to select
 * @param  {string} event event to trigger callback
 * @param  {function} callback function to call on event
 */
function addEventListenerToClass(className, event, callback) {
  var elems = document.getElementsByClassName(className);
  for (var i = 0; i < elems.length; i++) {
    elems[i].addEventListener(event, callback);
  }
}
// ====== END UTILITIES ======

// ====== START LIST EDITING FUNCTIONALITY ======
var editableList = document.getElementById("remove-album");
if (editableList) {
  document.getElementById("remove-album").addEventListener("click", toggleRemoveAlbumButtons);

  window.showRemoveAlbum = false;
  function toggleRemoveAlbumButtons() {
    if (!window.showRemoveAlbum) {
      window.showRemoveAlbum = true;
      showClass("delete-button");
      M.toast({html: "Click the 'X' to remove an album from the list", displayLength: 2500});
    } else {
      window.showRemoveAlbum = false;
      hideClass("delete-button");
    }
  }

  function addAlbumToList(appleAlbumID) {
    var listID = parseInt(window.location.pathname.replace("/lists/", ""));

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        var response = JSON.parse(xhr.responseText);
        listVueApp.albums.push(response.added_album);
        // hide delete buttons if they are shown
        window.showRemoveAlbum = true;
        toggleRemoveAlbumButtons();
        window.addAlbumModal.close();
      } else {
        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      }
    };
    xhr.open("PATCH", `/lists/${listID}`);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({action: "add_album", currentAlbum: appleAlbumID}));
  }

  function removeAlbumFromList(albumID) {
    var confirmed = confirm("Are you sure you want to remove the album from this list? You cannot undo this operation.");
    if (!confirmed) return;

    var listID = parseInt(window.location.pathname.replace("/lists/", ""));

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        // remove album from vue app
        var albumsIndex = listVueApp.albums.findIndex(a => a.id == albumID);
        listVueApp.albums.splice(albumsIndex, 1);

        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      } else {
        M.toast({html: "Unable to remove album from list"});
      }
    };
    xhr.open("PATCH", `/lists/${listID}`);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({action: "remove_album", albumID: albumID}));
  }

  function updateListTitle() {
    var listID = parseInt(window.location.pathname.replace("/lists/", ""));
    var newTitle = document.getElementById("list-name-input").value.trim();

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        var response = JSON.parse(xhr.responseText);
        listVueApp.listTitle = response.list_title;
        window.editListModal.close();
        M.toast({html: response.message});
      } else {
        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      }
    };
    xhr.open("PATCH", `/lists/${listID}`);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({action: "update_title", newTitle: newTitle}));
  }

  document.getElementById("list-name-input").addEventListener("keyup", function(e) {
    if (e.keyCode === 13) { updateListTitle(); }
  });

  const albumSearchSpinner = document.getElementById("add-album-search-spinner-container");
  function hideAlbumSearchSpinner() {
    if (albumSearchSpinner.classList.contains("hide")) return;
    albumSearchSpinner.classList.add("hide");
  }

  function showAlbumSearchSpinner() {
    albumSearchSpinner.classList.remove("hide");
  }

  document.getElementById("add-album-input").addEventListener("keydown", function(e) {
    if(e.keyCode == 13) {
      removeSelectedElement(".album-search-album");
      // display results inline with side-scroll
      document.getElementById("add-album-search-results").style.display = "inline-flex";
      removeSelectedElement("#add-album-search-result-warning");
      showAlbumSearchSpinner();

      var search = document.getElementById("add-album-input").value.trim();
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;

        if (xhr.status >= 200 && xhr.status < 300) {
          displayAlbumSearchResults(JSON.parse(xhr.responseText));
        } else {
          hideAlbumSearchSpinner();
          console.log('error', xhr);
        }
      };
      xhr.open("GET", `/api/apple/search/?search_string=${search}&offset=0`);
      xhr.send();
    }
  });

  function displayAlbumSearchResults(results) {
    const searchResultsContainer = document.getElementById("add-album-search-results");

    if (results.albums.length < 1) {
      hideAlbumSearchSpinner();
      searchResultsContainer.appendChild(stringToNode(
        `<div id="add-album-search-result-warning" class="center-align">
          <em class="grey-text text-darken-1">
            No albums match your search! Try another artist or album.
          </em>
        </div>`
      ));
      // required for warning element to display centered
      return document.getElementById("add-album-search-results").style.display = "block";
    }

    hideAlbumSearchSpinner();
    // display results inline with side-scroll
    document.getElementById("add-album-search-results").style.display = "inline-flex";
    for (let i = 0; i < results.albums.length; i++) {
      const album = results.albums[i];
      const albumCover = album.cover.replace("{w}", "230").replace("{h}", "230");
      searchResultsContainer.appendChild(stringToNode(
        `<div class="album-search-album" onclick="addAlbumToList(${album.appleAlbumID})">
          <img class="search-album-cover" src="${albumCover}">
          <p class="search-title">${album.title}</p>
          <p class="search-artist grey-text text-darken-1">${album.artist}</p>
        </div>`
      ));
    }
  }
}
// ====== END LIST EDITING FUNCTIONALITY ======


// ====== START FILTER FUNCTIONALITY ======
function selectChip(element) {
  element.classList.add("light-blue");
  element.classList.add("accent-4");
  element.classList.add("white-text");
}

function deselectChip(element) {
  element.classList.remove("light-blue");
  element.classList.remove("accent-4");
  element.classList.remove("white-text");
}

function toggleChipSelect(element) {
  element.classList.toggle("light-blue");
  element.classList.toggle("accent-4")
  element.classList.toggle("white-text");
}

function selectYearFilter(e) {
  toggleChipSelect(e.target);

  var index = listVueApp.yearFilters.indexOf(e.target.dataset.year);
  if (index == -1) {
    listVueApp.yearFilters.push(e.target.dataset.year);
  } else {
    listVueApp.yearFilters.splice(index, 1);
  }
}

function selectArtistFilter(e) {
  toggleChipSelect(e.target);

  var index = listVueApp.artistFilters.indexOf(e.target.dataset.artist);
  if (index == -1) {
    listVueApp.artistFilters.push(e.target.dataset.artist);
  } else {
    listVueApp.artistFilters.splice(index, 1);
  }
}

function selectTagFilter(e) {
  toggleChipSelect(e.target);

  var index = listVueApp.tagFilters.indexOf(e.target.dataset.tag);
  if (index == -1) {
    listVueApp.tagFilters.push(e.target.dataset.tag);
  } else {
    listVueApp.tagFilters.splice(index, 1);
  }
}

function removeFilter(e) {
  var filterToRemove = e.target.dataset.filter;

  switch (e.target.dataset.type) {
    case "year":
      var index = listVueApp.yearFilters.indexOf(filterToRemove);
      listVueApp.yearFilters.splice(index, 1);
      break;
    case "artist":
      var index = listVueApp.artistFilters.indexOf(filterToRemove);
      listVueApp.artistFilters.splice(index, 1);
      break;
    case "tag":
      var index = listVueApp.tagFilters.indexOf(filterToRemove);
      listVueApp.tagFilters.splice(index, 1);
  }
  listVueApp.resetSelectedAlbums();
  filterAll();
}

function hilightSelectedTagFilters() {
  var filterChips = document.getElementsByClassName("tag-filter");
  var selectedFilters = listVueApp.tagFilters;
  for (var i = 0; i < filterChips.length; i++) {
    var ele = filterChips[i];
    selectedFilters.includes(ele.dataset.tag) ? selectChip(ele) : deselectChip(ele);
  }
}

function hilightSelectedArtistFilters() {
  var filterChips = document.getElementsByClassName("artist-filter");
  var selectedFilters = listVueApp.artistFilters;
  for (var i = 0; i < filterChips.length; i++) {
    var ele = filterChips[i];
    selectedFilters.includes(ele.dataset.artist) ? selectChip(ele) : deselectChip(ele);
  }
}

function hilightSelectedYearFilters() {
  var filterChips = document.getElementsByClassName("year-filter");
  var selectedFilters = listVueApp.yearFilters;
  for (var i = 0; i < filterChips.length; i++) {
    var ele = filterChips[i];
    selectedFilters.includes(ele.dataset.year) ? selectChip(ele) : deselectChip(ele);
  }
}

function filterYears() {
  if (listVueApp.yearFilters.length === 0) return;
  listVueApp.selectedAlbums = listVueApp.selectedAlbums.filter(album =>
    listVueApp.yearFilters.includes(album.release_date.substr(0,4))
  );
}

function filterArtists() {
  if (listVueApp.artistFilters.length === 0) return;
  listVueApp.selectedAlbums = listVueApp.selectedAlbums.filter(album =>
    listVueApp.artistFilters.includes(album.artist)
  );
}

function filterTags() {
  if (listVueApp.tagFilters.length === 0) return;
  listVueApp.selectedAlbums = listVueApp.selectedAlbums.filter(album =>
    listVueApp.tagFilters.every(tag =>
      album.tags.map(t => t.text).includes(tag)
    )
  );
}

function filterAll() {
  filterYears();
  filterArtists();
  filterTags();
}

addEventListenerToClass("filter-btn", "click", function(e) {
  // these buttons just close the modal and the onCloseStart function for the
  // modals execute the list filtering
  window.yearFilterModal.close();
  window.artistFilterModal.close();
  window.tagFilterModal.close();
});

addEventListenerToClass("clear-filters", "click", function(e) {
  switch (e.target.dataset.type) {
    case "year":
      listVueApp.yearFilters = [];
      M.toast({html: "Year filters cleared", displayLength: 2500});
      break;
    case "artist":
      listVueApp.artistFilters = [];
      M.toast({html: "Artist filters cleared", displayLength: 2500});
      break;
    case "tag":
      listVueApp.tagFilters = [];
      M.toast({html: "Tag filters cleared", displayLength: 2500});
  }
  listVueApp.resetSelectedAlbums();
  filterAll();

  hilightSelectedArtistFilters();
  hilightSelectedTagFilters();
  hilightSelectedYearFilters();
});
// ====== END FILTER FUNCTIONALITY ======

/**
 * setURIparams - description
 * @param  {string} type the type of filter, i.e. "tags"
 * @param  {array} filter an array of strings representing filters to apply, i.e. ["Rock", "Emo"]
 */
function setURIparams(type, filter) {
  let url = new URL(document.location);
  if (filter.length === 0) {
    // if no filters of this type, entirely remove unused param from the URL
    url.searchParams.delete(type);
    return history.replaceState({}, '', url);
  }

  var encodedFilter = encodeURIComponent(filter.join(",,"));
  url.searchParams.set(type, encodedFilter);
  history.replaceState({}, '', url); // replace history entry
}

/**
 * getURIparam - description
 * @param  {string} type the type of uri param, i.e. "tags"
 */
function getURIparam(type) {
  let url = new URL(document.location);
  let paramValue = url.searchParams.get(type);

  return paramValue ? decodeURIComponent(paramValue).split(",,") : [];
}
