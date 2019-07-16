var connectionsPage = {
  closeToast: function() {
    var toastElement = document.querySelector('.toast');
    var toastInstance = M.Toast.getInstance(toastElement);
    toastInstance.dismiss();
  },
  closeToastsOnClick: function(e) {
    var parent = e.target.parentNode;
    var isToast = (parent.classList && parent.classList.contains("toast")) || parent.id == "toast-container";
    if (isToast) {
      connectionsPage.closeToast();
    }
  },
  hideSpinner: function() {
    if (connectionsPage.spinner.classList.contains("hide")) {
      return;
    }
    connectionsPage.spinner.classList.add("hide");
  },
  showSpinner: function() {
    connectionsPage.spinner.classList.remove("hide");
  },
  executeAlbumSearch: function() {
    removeSelectedElement(".album");
    removeSelectedElement("#warning");
    connectionsPage.showSpinner();

    var search = connectionsPage.searchInput.value.trim();
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        connectionsPage.displaySearchResults(JSON.parse(xhr.responseText));
      } else {
        connectionsPage.hideSpinner();
        console.log('error', xhr);
      }
    };
    xhr.open("GET", `/api/apple/search/?search_string=${search}&offset=0`);
    xhr.send();
  },
  clearSearchInput: function() {
    connectionsPage.searchInput.value = "";
    connectionsPage.searchInput.focus();
  },
  displaySearchResults: function(results) {
    const resultsContainer = document.getElementById("connection-search-results");

    if (results.albums.length < 1) {
      connectionsPage.hideSpinner();
      return resultsContainer.appendChild(stringToNode(
        `<div id="warning" style="width:100%;margin-top:25px;" class="center-align">
          <em class="grey-text text-darken-1">
            No albums match your search! Try another artist or album.
          </em>
        </div>`
      ));
    }

    connectionsPage.hideSpinner();
    for (let i = 0; i < results.albums.length; i++) {
      const album = results.albums[i];
      const albumCover = album.cover.replace("{w}", "200").replace("{h}", "200");
      resultsContainer.appendChild(stringToNode(
        `<div class="album" onclick="connectionsPage.addConnection(${album.appleAlbumID})">
          <img class="responsive-img album-cover" src="${albumCover}">
          <p class="title">${album.title}</p>
          <p class="artist grey-text text-darken-1">${album.artist}</p>
        </div>`
      ));
    }
  },
  addConnection: function(appleAlbumID) {
    const currentAlbum = parseInt(
      new URLSearchParams(window.location.search).get("parent_album")
    );
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        var successMessage = JSON.parse(xhr.responseText).message;
        M.toast({html: successMessage});
      } else {
        var failureMessage = JSON.parse(xhr.responseText).message;
        M.toast({html: failureMessage});
      }
    };
    xhr.open("POST", "/connections");
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({parentAlbum: currentAlbum, childAlbum: appleAlbumID}));
  },
};

// ====== START UTILITY FUNCTIONS ======
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

// ====== END UTILITY FUNCTIONS ======

document.addEventListener('DOMContentLoaded', function() {
  connectionsPage.spinner = document.getElementById("spinner-container");
  connectionsPage.searchInput = document.getElementById("connection-search-input");
  connectionsPage.clearSearchInputBtn = document.getElementById("clear-search-input-btn");

  connectionsPage.searchInput.focus();
  connectionsPage.searchInput.addEventListener("keydown", function(e) {
    if(e.keyCode == 13) {
      connectionsPage.executeAlbumSearch();
    }
  }, {passive: true});
  connectionsPage.clearSearchInputBtn.addEventListener("click", connectionsPage.clearSearchInput);

  document.addEventListener("click", function(e) {
    connectionsPage.closeToastsOnClick(e);
  }, {passive: true});
}, {passive: true});
