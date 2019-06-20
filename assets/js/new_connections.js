// ====== START MATERIALIZE ======
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
// ====== END MATERIALIZE ======

// ====== START UTILITY FUNCTIONS ======
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

const spinner = document.getElementById("spinner-container");
function hideSpinner() {
  if (spinner.classList.contains("hide")) return;
  spinner.classList.add("hide");
}

function showSpinner() {
  spinner.classList.remove("hide");
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
// ====== END UTILITY FUNCTIONS ======

document.getElementById("connection-search-input").focus();

document.getElementById("connection-search-input").addEventListener("keydown", function(e) {
  if(e.keyCode == 13) {
    removeSelectedElement(".album");
    removeSelectedElement("#warning")
    showSpinner();

    var search = document.getElementById("connection-search-input").value.trim();
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        displayResults(JSON.parse(xhr.responseText));
      } else {
        hideSpinner();
        console.log('error', xhr);
      }
    };
    xhr.open("GET", `/api/apple/search/?search_string=${search}&offset=0`);
    xhr.send();
  }
});

document.getElementById("clear-search-input-btn").addEventListener("click", function(e) {
  var searchInput = document.getElementById("connection-search-input");
  searchInput.value = "";
  searchInput.focus();
});

function displayResults(results) {
  const resultsContainer = document.getElementById("connection-search-results");

  if (results.albums.length < 1) {
    hideSpinner();
    return resultsContainer.appendChild(stringToNode(
      `<div id="warning" style="width:100%;margin-top:25px;" class="center-align">
        <em class="grey-text text-darken-1">
          No albums match your search! Try another artist or album.
        </em>
      </div>`
    ));
  }

  hideSpinner();
  for (let i = 0; i < results.albums.length; i++) {
    const album = results.albums[i];
    const albumCover = album.cover.replace("{w}", "200").replace("{h}", "200")
    resultsContainer.appendChild(stringToNode(
      `<div class="album" onclick="addConnection(${album.appleAlbumID})">
        <img class="responsive-img album-cover" src="${albumCover}">
        <p class="title">${album.title}</p>
        <p class="artist grey-text text-darken-1">${album.artist}</p>
      </div>`
    ));
  }
}

function addConnection(appleAlbumID) {
  const currentAlbum = parseInt(
    new URLSearchParams(window.location.search).get("parent_album")
  );
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState !== 4) return;

    if (xhr.status >= 200 && xhr.status < 300) {
      var message = JSON.parse(xhr.responseText).message;
      M.toast({html: message});
    } else {
      var message = JSON.parse(xhr.responseText).message;
      M.toast({html: message});
    }
  };
  xhr.open("POST", "/connections");
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
  xhr.send(JSON.stringify({parentAlbum: currentAlbum, childAlbum: appleAlbumID}));
}
