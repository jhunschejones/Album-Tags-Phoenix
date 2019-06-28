var editableList = document.getElementById("remove-album");

if (editableList) {
  // ====== START MATERIALIZE ======
  // initialize floating action button
  document.addEventListener('DOMContentLoaded', function() {
    var elems = document.querySelectorAll('.fixed-action-btn');
    var instances = M.FloatingActionButton.init(elems, {
      direction: "top",
      hoverEnabled: false
    });

    // close expanded fabs when user clicks somewhere not on the buttons
    document.addEventListener("click", function(e) {
      var clickedFAB = [
        "lists-fab-button", "add-lists", "edit-lists", "remove-album"
      ].includes(e.target.parentNode.id);

      if (!clickedFAB) {
        for (let i = 0; i < instances.length; i++) {
          instances[i].close();
        }
      }
    });
  });

  // close toasts on click
  document.addEventListener("click", function(e) {
    var parent = e.target.parentNode
    var isToast = (parent.classList && parent.classList.contains("toast")) || parent.id == "toast-container";
    if (isToast) { closeToast(); }
  });

  function closeToast() {
    var toastElement = document.querySelector('.toast');
    var toastInstance = M.Toast.getInstance(toastElement);
    toastInstance.dismiss();
  }

  // initialize modals
  document.addEventListener('DOMContentLoaded', function() {
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
  });
  // ====== END MATERIALIZE ======
}

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
// ====== END UTILITIES ======

window.showRemoveAlbum = false;
function toggleRemoveAlbumButtons() {
  if (!window.showRemoveAlbum) {
    window.showRemoveAlbum = true;
    showClass("delete-button");
  } else {
    window.showRemoveAlbum = false;
    hideClass("delete-button");
  }
}

if (editableList) {
  document.getElementById("remove-album").addEventListener("click", toggleRemoveAlbumButtons);

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
        // M.toast({html: response.message});
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
