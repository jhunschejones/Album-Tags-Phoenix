// ====== START UTILITY FUNCTIONS ======
function truncate(str, len){
  // handle long string with no spaces
  if (str.lastIndexOf(' ') == -1) {return str.substr(0, len-9) + '...';}

  // set up the substring
  const subString = str.substr(0, len-1);
  // add elipse after last complete word & trim trailing comma
  return (subString.substr(0, subString.lastIndexOf(' ')).replace(/(^[,\s]+)|([,\s]+$)/g, '') + '...');
}
// ====== END UTILITY FUNCTIONS ======

// ====== START MATERIALIZE ======
// set up select from existing lists select/dropdown element
function initializeSelectElement() {
  var elems = document.querySelectorAll('select');
  var instances = M.FormSelect.init(elems, {});
  window.existingListSelect = instances[0];

  window.existingListSelect.dropdown.options.onCloseStart = function() {
    // manually truncate value placed in dropdown field when selected
    var width = document.getElementsByClassName("select-dropdown")[0].offsetWidth;
    // 37 characters at this font size is about 250px, or 6.75px / character
    // subtract 30px for button width
    var truncateCharacters = (width - 30) / 6.75;
    var selection = document.getElementsByClassName("select-dropdown")[0].value;

    if (selection.length > truncateCharacters) {
      document.getElementsByClassName("select-dropdown")[0].value = truncate(selection, truncateCharacters);
    }
  }

  // close dropdown when clicking outside select options
  document.addEventListener("click", function(e) {
    if (!e.target.classList.contains("select-dropdown")) {
      window.existingListSelect.dropdown.close();
    }
  });
}
document.addEventListener('DOMContentLoaded', function() {
  initializeSelectElement();
}, {passive: true});

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

document.getElementById("add-to-list-btn").addEventListener("click", function() {
  var list = window.existingListSelect.getSelectedValues()[0];
  if (list === "") return;
  if (list === "favorites") return addToFavorites();

  const currentAlbum = parseInt(
    new URLSearchParams(window.location.search).get("album")
  );
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState !== 4) return;

    if (xhr.status >= 200 && xhr.status < 300) {
      // reset selected option to default
      window.existingListSelect.destroy();
      document.getElementById("placeholder").selected = true;
      initializeSelectElement();

      var response = JSON.parse(xhr.responseText);
      M.toast({html: response.message});
    } else {
      // reset selected option to default
      window.existingListSelect.destroy();
      document.getElementById("placeholder").selected = true;
      initializeSelectElement();
      M.toast({html: xhr.responseText.replace(/\"/g, "")});
    }
  };
  xhr.open("PATCH", `/lists/${list}`);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
  xhr.send(JSON.stringify({action: "add_album", currentAlbum: currentAlbum}));
}, {passive: true});

function addToFavorites() {
  const currentAlbum = parseInt(
    new URLSearchParams(window.location.search).get("album")
  );
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState !== 4) return;

    if (xhr.status >= 200 && xhr.status < 300) {
      // reset selected option to default
      window.existingListSelect.destroy();
      document.getElementById("placeholder").selected = true;
      initializeSelectElement();

      M.toast({html: xhr.responseText.replace(/\"/g, "")});
    } else {
      // reset selected option to default
      window.existingListSelect.destroy();
      document.getElementById("placeholder").selected = true;
      initializeSelectElement();
      M.toast({html: xhr.responseText.replace(/\"/g, "")});
    }
  };
  xhr.open("PATCH", "/lists/favorites");
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
  xhr.send(JSON.stringify({action: "add_favorite", currentAlbum: currentAlbum}));
}

document.getElementById("add-to-new-list-btn").addEventListener("click", function() {
  var newListName = document.getElementById("new-list-name").value.trim();

  const currentAlbum = parseInt(
    new URLSearchParams(window.location.search).get("album")
  );
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState !== 4) return;

    if (xhr.status >= 200 && xhr.status < 300) {
      document.getElementById("new-list-name").value = "";
      M.toast({html: xhr.responseText.replace(/\"/g, "")});
    } else {
      M.toast({html: xhr.responseText.replace(/\"/g, "")});
    }
  };
  xhr.open("POST", "/lists");
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
  xhr.send(JSON.stringify({
    currentAlbum: currentAlbum,
    private: false,
    title: newListName
  }));

}, {passive: true});

document.getElementById("new-list-name").addEventListener("keyup", function(e) {
  if (e.keyCode === 13) {
    document.getElementById("add-to-new-list-btn").click();
  }
});
