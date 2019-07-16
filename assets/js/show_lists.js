var listPage = {
  initializeEditListModal: function() {
    var editListModalElement = document.getElementById("edit-list-modal");
    listPage.editListModal = M.Modal.init(editListModalElement, {
      onOpenEnd: function() {
        var editListInput = document.getElementById("list-name-input");
        editListInput.focus();
        // move cursor to end of input field
        editListInput.selectionStart = editListInput.selectionEnd = editListInput.value.length;
    }});
  },
  initializeAddAlbumModal: function() {
    var addAlbumModalElement = document.getElementById("add-album-modal");
    listPage.addAlbumModal = M.Modal.init(addAlbumModalElement, {
      onOpenEnd: function() {
        var addAlbumInput = document.getElementById("add-album-input");
        addAlbumInput.focus();
    }});
  },
  closeModalOnClickAway: function(e) {
    if (e.target.classList.contains("modal-overlay")) {
      listPage.tagFilterModal.close();
      listPage.artistFilterModal.close();
      listPage.yearFilterModal.close();
    }
  },
  closeToast: function() {
    var toastElement = document.querySelector('.toast');
    var toastInstance = M.Toast.getInstance(toastElement);
    toastInstance.dismiss();
  },
  closeToastsOnClick: function(e) {
    var parent = e.target.parentNode;
    var isToast = (parent && parent.classList && parent.classList.contains("toast")) || (parent && parent.id == "toast-container");
    if (isToast) {
      listPage.closeToast();
    }
  },
  initializeMainFloatingActionButton: function() {
    var mainFABelement = document.getElementById("lists-fab-button");
    listPage.mainFloatingActionButton = M.FloatingActionButton.init(mainFABelement, {
      direction: "top",
      hoverEnabled: false
    });
  },
  closeFloatingActionButtonWhenClickAway: function(e) {
    var clickedMainFAB = [
      "show-buttons", "add-lists", "edit-lists", "remove-album", "filter-fab"
    ].includes(e.target.parentNode.id);

    if (!clickedMainFAB) {
      listPage.mainFloatingActionButton.close();
    }
  },
  showFilterMenu: function() {
    setTimeout(() => {
      document.getElementById("bottom-filters").classList.remove("hide");
    }, 150);
  },
  closeFilterMenu: function() {
    document.getElementById("bottom-filters").classList.add("hide");
  },
  clearAllFilters: function() {
    listVueApp.yearFilters = [];
    listVueApp.artistFilters = [];
    listVueApp.tagFilters = [];
    listVueApp.resetSelectedAlbums();
    listPage.filterAll();

    listPage.hilightSelectedArtistFilters();
    listPage.hilightSelectedTagFilters();
    listPage.hilightSelectedYearFilters();
    document.getElementById("bottom-filters").classList.add("hide");
    M.toast({html: "All filters cleared", displayLength: 2500});
  },
  initializeYearFilterModal: function() {
    var yearFilterModalElement = document.getElementById("year-filter-modal");
    listPage.yearFilterModal = M.Modal.init(yearFilterModalElement, {
      onCloseStart: function() {
        // filter albums on modal close in case user forgets to click "filter" button
        listVueApp.resetSelectedAlbums();
        listPage.filterAll();
      }
    });
  },
  initializeArtistFitlerModal: function() {
    var artistFilterModalElement = document.getElementById("artist-filter-modal");
    listPage.artistFilterModal = M.Modal.init(artistFilterModalElement, {
      onCloseStart: function() {
        // filter albums on modal close in case user forgets to click "filter" button
        listVueApp.resetSelectedAlbums();
        listPage.filterAll();
      }
    });
  },
  initializeTagFilterModal: function() {
    var tagFilterModalElement = document.getElementById("tag-filter-modal");
    listPage.tagFilterModal = M.Modal.init(tagFilterModalElement, {
      onCloseStart: function() {
        // filter albums on modal close in case user forgets to click "filter" button
        listVueApp.resetSelectedAlbums();
        listPage.filterAll();
      }
    });
  },
  toggleRemoveAlbumButtons: function() {
    if (!listPage.showRemoveAlbum) {
      listPage.showRemoveAlbum = true;
      showClass("delete-button");
      M.toast({html: `
        <span>
          Click the <i class='small material-icons' style='vertical-align:middle;'>highlight_off</i> to remove an album from the list
        </span>
      `, displayLength: 2500});
    } else {
      listPage.showRemoveAlbum = false;
      hideClass("delete-button");
    }
  },
  addAlbumToList: function(appleAlbumID) {
    var listID = parseInt(window.location.pathname.replace("/lists/", ""));

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) { return; }

      if (xhr.status >= 200 && xhr.status < 300) {
        var response = JSON.parse(xhr.responseText);
        listVueApp.albums.push(response.added_album);

        // hide delete buttons if they are shown
        listPage.showRemoveAlbum = true;
        listPage.toggleRemoveAlbumButtons();
        setTimeout(() => {
          listVueApp.resetSelectedAlbums();
          listPage.filterAll();
        }, 5);
        listPage.addAlbumModal.close();
      } else {
        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      }
    };
    xhr.open("PATCH", `/lists/${listID}`);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({action: "add_album", currentAlbum: appleAlbumID}));
  },
  removeAlbumFromList: function(albumID) {
    var confirmed = confirm("Are you sure you want to remove the album from this list? You cannot undo this operation.");
    if (!confirmed) { return; }

    var listID = parseInt(window.location.pathname.replace("/lists/", ""));

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) { return; }

      if (xhr.status >= 200 && xhr.status < 300) {
        // remove album from vue app
        var albumsIndex = listVueApp.albums.findIndex(a => a.id == albumID);
        listVueApp.albums.splice(albumsIndex, 1);
        setTimeout(() => {
          listVueApp.resetSelectedAlbums();
          listPage.filterAll();
          // clear filters if there are now no matching results
          if (listVueApp.selectedAlbums.length == 0) {
            listVueApp.yearFilters = [];
            listVueApp.artistFilters = [];
            listVueApp.tagFilters = [];
            listVueApp.resetSelectedAlbums();
            listPage.filterAll();
          }
        }, 5);
        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      } else {
        M.toast({html: "Unable to remove album from list"});
      }
    };
    xhr.open("PATCH", `/lists/${listID}`);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({action: "remove_album", albumID: albumID}));
  },
  updateListTitle: function() {
    var listID = parseInt(window.location.pathname.replace("/lists/", ""));
    var newTitle = document.getElementById("list-name-input").value.trim();

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) { return; }

      if (xhr.status >= 200 && xhr.status < 300) {
        var response = JSON.parse(xhr.responseText);
        listVueApp.listTitle = response.list_title;
        listPage.editListModal.close();
        M.toast({html: response.message});
      } else {
        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      }
    };
    xhr.open("PATCH", `/lists/${listID}`);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({action: "update_title", newTitle: newTitle}));
  },
  searchForAlbumsToAddToList: function() {
    removeSelectedElement(".album-search-album");
    // display results inline with side-scroll
    document.getElementById("add-album-search-results").style.display = "inline-flex";
    removeSelectedElement("#add-album-search-result-warning");
    listPage.showAlbumSearchSpinner();

    var search = document.getElementById("add-album-input").value.trim();
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) { return; }

      if (xhr.status >= 200 && xhr.status < 300) {
        listPage.displayAlbumSearchResults(JSON.parse(xhr.responseText));
      } else {
        listPage.hideAlbumSearchSpinner();
        console.log('error', xhr);
      }
    };
    xhr.open("GET", `/api/apple/search/?search_string=${search}&offset=0`);
    xhr.send();
  },
  showAlbumSearchSpinner: function() {
    listPage.albumSearchSpinner.classList.remove("hide");
  },
  hideAlbumSearchSpinner: function() {
    if (!listPage.albumSearchSpinner.classList.contains("hide")) {
      listPage.albumSearchSpinner.classList.add("hide");
    }
  },
  displayAlbumSearchResults: function(results) {
    const searchResultsContainer = document.getElementById("add-album-search-results");

    if (results.albums.length < 1) {
      listPage.hideAlbumSearchSpinner();
      searchResultsContainer.appendChild(stringToNode(
        `<div id="add-album-search-result-warning" class="center-align">
          <em class="grey-text text-darken-1">
            No albums match your search! Try another artist or album.
          </em>
        </div>`
      ));
      // required for warning element to display centered
      document.getElementById("add-album-search-results").style.display = "block";
    }

    listPage.hideAlbumSearchSpinner();
    // display results inline with side-scroll
    document.getElementById("add-album-search-results").style.display = "inline-flex";
    for (let i = 0; i < results.albums.length; i++) {
      const album = results.albums[i];
      const albumCover = album.cover.replace("{w}", "230").replace("{h}", "230");
      searchResultsContainer.appendChild(stringToNode(
        `<div class="album-search-album" onclick="listPage.addAlbumToList(${album.appleAlbumID})">
          <img class="search-album-cover" src="${albumCover}">
          <p class="search-title">${album.title}</p>
          <p class="search-artist grey-text text-darken-1">${album.artist}</p>
        </div>`
      ));
    }
  },
  selectChip: function(element) {
    element.classList.add("light-blue");
    element.classList.add("accent-4");
    element.classList.add("white-text");
  },
  deselectChip: function(element) {
    element.classList.remove("light-blue");
    element.classList.remove("accent-4");
    element.classList.remove("white-text");
  },
  toggleChipSelect: function(element) {
    element.classList.toggle("light-blue");
    element.classList.toggle("accent-4");
    element.classList.toggle("white-text");
  },
  selectYearFilter: function(e) {
    listPage.toggleChipSelect(e.target);

    var index = listVueApp.yearFilters.indexOf(e.target.dataset.year);
    if (index == -1) {
      listVueApp.yearFilters.push(e.target.dataset.year);
    } else {
      listVueApp.yearFilters.splice(index, 1);
    }
  },
  selectArtistFilter: function(e) {
    listPage.toggleChipSelect(e.target);

    var index = listVueApp.artistFilters.indexOf(e.target.dataset.artist);
    if (index == -1) {
      listVueApp.artistFilters.push(e.target.dataset.artist);
    } else {
      listVueApp.artistFilters.splice(index, 1);
    }
  },
  selectTagFilter: function(e) {
    listPage.toggleChipSelect(e.target);

    var index = listVueApp.tagFilters.indexOf(e.target.dataset.tag);
    if (index == -1) {
      listVueApp.tagFilters.push(e.target.dataset.tag);
    } else {
      listVueApp.tagFilters.splice(index, 1);
    }
    listVueApp.resetSelectedAlbums();
    listPage.filterAll();
    // filter as the user clicks tags to avoid combinations of tags that return
    // no results
    setTimeout(() => { listPage.hilightSelectedTagFilters(); }, 10);
  },
  removeFilter: function(e) {
    var filterToRemove = e.target.dataset.filter;

    switch (e.target.dataset.type) {
      case "year":
        var yearIndex = listVueApp.yearFilters.indexOf(filterToRemove);
        listVueApp.yearFilters.splice(yearIndex, 1);
        break;
      case "artist":
        var artistIndex = listVueApp.artistFilters.indexOf(filterToRemove);
        listVueApp.artistFilters.splice(artistIndex, 1);
        break;
      case "tag":
        var tagIndex = listVueApp.tagFilters.indexOf(filterToRemove);
        listVueApp.tagFilters.splice(tagIndex, 1);
    }
    listVueApp.resetSelectedAlbums();
    listPage.filterAll();
  },
  hilightSelectedTagFilters: function() {
    var filterChips = document.getElementsByClassName("tag-filter");
    var selectedFilters = listVueApp.tagFilters;
    for (var i = 0; i < filterChips.length; i++) {
      var element = filterChips[i];
      if (selectedFilters.includes(element.dataset.tag)) {
        listPage.selectChip(element);
      } else {
        listPage.deselectChip(element);
      }
    }
  },
  hilightSelectedArtistFilters: function() {
    var filterChips = document.getElementsByClassName("artist-filter");
    var selectedFilters = listVueApp.artistFilters;
    for (var i = 0; i < filterChips.length; i++) {
      var element = filterChips[i];
      if (selectedFilters.includes(element.dataset.artist)) {
        listPage.selectChip(element);
      } else {
        listPage.deselectChip(element);
      }
    }
  },
  hilightSelectedYearFilters: function() {
    var filterChips = document.getElementsByClassName("year-filter");
    var selectedFilters = listVueApp.yearFilters;
    for (var i = 0; i < filterChips.length; i++) {
      var element = filterChips[i];
      if (selectedFilters.includes(element.dataset.year)) {
        listPage.selectChip(element);
      } else {
        listPage.deselectChip(element);
      }
    }
  },
  filterYears: function() {
    if (listVueApp.yearFilters.length === 0) { return; }
    listVueApp.selectedAlbums = listVueApp.selectedAlbums.filter(album =>
      listVueApp.yearFilters.includes(album.release_date.substr(0,4))
    );
  },
  filterArtists: function() {
    if (listVueApp.artistFilters.length === 0) { return; }
    listVueApp.selectedAlbums = listVueApp.selectedAlbums.filter(album =>
      listVueApp.artistFilters.includes(album.artist)
    );
  },
  filterTags: function() {
    if (listVueApp.tagFilters.length === 0) { return; }
    listVueApp.selectedAlbums = listVueApp.selectedAlbums.filter(album =>
      listVueApp.tagFilters.every(tag =>
        album.tags.map(t => t.text).includes(tag)
      )
    );
  },
  clearSpecificFilter: function(e) {
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
    listPage.filterAll();

    listPage.hilightSelectedArtistFilters();
    listPage.hilightSelectedTagFilters();
    listPage.hilightSelectedYearFilters();
  },
  filterAll: function() {
    listPage.filterYears();
    listPage.filterArtists();
    listPage.filterTags();
  },
  setURIparams: function(type, filter) {
    let url = new URL(document.location);
    if (filter.length === 0) {
      // if no filters of this type, entirely remove unused param from the URL
      url.searchParams.delete(type);
      return history.replaceState({}, '', url);
    }

    var encodedFilter = encodeURIComponent(filter.join(",,"));
    url.searchParams.set(type, encodedFilter);
    history.replaceState({}, '', url); // replace history entry
  },
  getURIparam: function(type) {
    let url = new URL(document.location);
    let paramValue = url.searchParams.get(type);

    return paramValue ? decodeURIComponent(paramValue).split(",,") : [];
  }
};

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
    removeAlbum: function(albumID) { listPage.removeAlbumFromList(albumID); },
    resetSelectedAlbums: function() {
      var albums = JSON.parse(JSON.stringify(this.albums));

      if (listUserID) {
        // filter tags down to just those made by the list creator if this is a user list
        for (var i = 0; i < albums.length; i++) {
          var album = albums[i];
          album.tags = album.tags.filter(t => t.user_id == this.listUserID);
        }
      }

      this.selectedAlbums = albums.sort(function(a, b) {
        if (a.release_date < b.release_date) { return 1; }
        if (a.release_date > b.release_date) { return -1; }
        return 0;
      });
    }
  },
  computed: {
    selectedAlbumsCount: function () { return this.selectedAlbums.length; },
    artists: function() {
      return Array.from(new Set(
        this.selectedAlbums.slice().map(a => a.artist).sort(function(a, b) {
          var nameA = a.toUpperCase();
          var nameB = b.toUpperCase();

          if (nameA < nameB) { return -1; }
          if (nameA > nameB) { return 1; }

          return 0; // names are equal
        })
      ));
    },
    years: function() {
      return Array.from(new Set(
        this.selectedAlbums.slice().map(a => a.release_date.substr(0,4))
      ));
    },
    tags: function() {
      return Array.from(new Set(this.selectedAlbums.slice().map(a =>
        a.tags.map(t => t.text)).flat().sort()
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
      listPage.setURIparams("years", updatedValue);
    },
    tagFilters: function(updatedValue) {
      listPage.setURIparams("tags", updatedValue);
    },
    artistFilters: function(updatedValue) {
      listPage.setURIparams("artists", updatedValue);
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
    this.artistFilters = listPage.getURIparam("artists");
    this.yearFilters = listPage.getURIparam("years");
    this.tagFilters = listPage.getURIparam("tags");

    // vue app methods and data are not fully availible to external functions
    // until everything is fully loaded in the DOM
    document.addEventListener('DOMContentLoaded', listPage.filterAll);
  }
});
// ====== END VUE APP ======

document.addEventListener('DOMContentLoaded', function() {

  var editableList = document.getElementById("remove-album");

  if (editableList) {
    var editListBtn = document.getElementById("edit-list");
    var addAlbumBtn = document.getElementById("add-album");
    var removeAlbumBtn = document.getElementById("remove-album");
    var clearListNameInputBtn = document.getElementById("clear-list-name-input-btn");
    var clearAlbumInputBtn = document.getElementById("clear-add-album-input-btn");
    var newListNameInput = document.getElementById("list-name-input");
    var albumSearchInput = document.getElementById("add-album-input");
    listPage.listNameInput = document.getElementById("list-name-input");
    listPage.albumInput = document.getElementById("add-album-input");
    listPage.albumSearchSpinner = document.getElementById("add-album-search-spinner-container");

    listPage.initializeEditListModal();
    listPage.initializeAddAlbumModal();

    removeAlbumBtn.addEventListener("click", listPage.toggleRemoveAlbumButtons);
    editListBtn.addEventListener("click", function() {
      listPage.editListModal.open();
    });
    addAlbumBtn.addEventListener("click", function() {
      listPage.addAlbumModal.open();
    });
    clearListNameInputBtn.addEventListener("click", function() {
      listNameInput.value = "";
      listNameInput.focus();
    });
    clearAlbumInputBtn.addEventListener("click", function() {
      listPage.albumInput.value = "";
      listPage.albumInput.focus();
    });
    newListNameInput.addEventListener("keyup", function(e) {
      if (e.keyCode === 13) { listPage.updateListTitle(); }
    });
    albumSearchInput.addEventListener("keydown", function(e) {
      if(e.keyCode == 13) { listPage.searchForAlbumsToAddToList(); }
    });
  }

  var showFilterMenuBtn = document.getElementById("show-filters");
  var closeFilterMenuBtn = document.getElementById("close-filter-menu");
  var clearAllFiltersBtn = document.getElementById("clear-all-filters");
  var menuHambergerBtn = document.getElementById("open-sidenav");
  var openYearFiltersBtn = document.getElementById("year-filter-btn");
  var openArtistFiltersBtn = document.getElementById("artist-filter-btn");
  var openTagFiltersBtn = document.getElementById("tag-filter-btn");
  listPage.showRemoveAlbum = false;

  listPage.initializeMainFloatingActionButton();
  listPage.initializeYearFilterModal();
  listPage.initializeArtistFitlerModal();
  listPage.initializeTagFilterModal();

  showFilterMenuBtn.addEventListener("click", listPage.showFilterMenu);
  closeFilterMenuBtn.addEventListener("click", listPage.closeFilterMenu);
  clearAllFiltersBtn.addEventListener("click", listPage.clearAllFilters);
  menuHambergerBtn.addEventListener("click", listPage.closeFilterMenu);
  openYearFiltersBtn.addEventListener("click", function() {
    listPage.hilightSelectedYearFilters();
    listPage.yearFilterModal.open();
  });
  openArtistFiltersBtn.addEventListener("click", function() {
    listPage.hilightSelectedArtistFilters();
    listPage.artistFilterModal.open();
  });
  openTagFiltersBtn.addEventListener("click", function() {
    listPage.hilightSelectedTagFilters();
    listPage.tagFilterModal.open();
  });
  document.addEventListener("click", function(e) {
    listPage.closeToastsOnClick(e);
  });
  document.addEventListener("click", function(e) {
    if (!e.target.parentNode) {
      return;
    }
    listPage.closeFloatingActionButtonWhenClickAway(e);
  }, {passive: true});
  document.addEventListener("scroll", function() {
    setTimeout(() => { listPage.closeFilterMenu(); }, 50);
  }, {passive: true});
  document.addEventListener("click", function(e) {
    listPage.closeModalOnClickAway(e);
  }, {passive: true});
  addEventListenerToClass("clear-filters", "click", function(e) {
    listPage.clearSpecificFilter(e);
  });
  addEventListenerToClass("filter-btn", "click", function(e) {
    // these buttons just close the modals and the `onCloseStart` function for
    // the modals themselves execute the actual list filtering
    listPage.yearFilterModal.close();
    listPage.artistFilterModal.close();
    listPage.tagFilterModal.close();
  });
});

// ====== START UTILITIES ======
/**
 * Show all elements matching a class selector
 * @param  {string} className class to show
 */
function showClass(className) {
  var elems = document.getElementsByClassName(className);
  for (var i = 0; i < elems.length; i++) {
    elems[i].classList.remove("hide");
  }
}

/**
 * Hide all elements matching a class selector
 * @param  {string} className class to hide
 */
function hideClass(className) {
  var elems = document.getElementsByClassName(className);
  for (var i = 0; i < elems.length; i++) {
    elems[i].classList.add("hide");
  }
}

/**
 * Add an event listener to each element on the page matching a given class
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
