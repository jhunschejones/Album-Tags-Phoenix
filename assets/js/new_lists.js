var listPage = {
  initializeSelectElement: function() {
    var elems = document.querySelectorAll('select');
    var instances = M.FormSelect.init(elems, {});
    listPage.existingListsSelect = instances[0];

    listPage.existingListsSelect.dropdown.options.onCloseStart = function() {
      // manually truncate value placed in dropdown field when selected
      var width = document.getElementsByClassName("select-dropdown")[0].offsetWidth;
      // 37 characters at this font size is about 250px, or 6.75px / character
      // subtract 30px for button width
      var truncateCharacters = (width - 30) / 6.75;
      var selection = document.getElementsByClassName("select-dropdown")[0].value;

      if (selection.length > truncateCharacters) {
        document.getElementsByClassName("select-dropdown")[0].value = truncate(selection, truncateCharacters);
      }
    };

    // close dropdown when clicking outside select options
    document.addEventListener("click", function(e) {
      if (!e.target.classList.contains("select-dropdown")) {
        listPage.existingListsSelect.dropdown.close();
      }
    });
  },
  closeToast: function() {
    var toastElement = document.querySelector('.toast');
    var toastInstance = M.Toast.getInstance(toastElement);
    toastInstance.dismiss();
  },
  closeToastsOnClick: function(e) {
    var parent = e.target.parentNode;
    var isToast = (parent.classList && parent.classList.contains("toast")) || parent.id == "toast-container";
    if (isToast) {
      listPage.closeToast();
    }
  },
  addAlbumToExistingList: function() {
    var list = listPage.existingListsSelect.getSelectedValues()[0];
    if (list === "") {
      return;
    } else if (list === "favorites") {
      return listPage.addAlbumToFavoritesList();
    }

    const currentAlbum = parseInt(
      new URLSearchParams(window.location.search).get("album")
    );
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        // reset selected option to default
        listPage.existingListsSelect.destroy();
        document.getElementById("placeholder").selected = true;
        listPage.initializeSelectElement();

        var response = JSON.parse(xhr.responseText);
        M.toast({html: response.message});
      } else {
        // reset selected option to default
        listPage.existingListsSelect.destroy();
        document.getElementById("placeholder").selected = true;
        listPage.initializeSelectElement();
        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      }
    };
    xhr.open("PATCH", `/lists/${list}`);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({action: "add_album", currentAlbum: currentAlbum}));
  },
  addAlbumToFavoritesList: function() {
    const currentAlbum = parseInt(
      new URLSearchParams(window.location.search).get("album")
    );
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        // reset selected option to default
        listPage.existingListsSelect.destroy();
        document.getElementById("placeholder").selected = true;
        listPage.initializeSelectElement();

        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      } else {
        // reset selected option to default
        listPage.existingListsSelect.destroy();
        document.getElementById("placeholder").selected = true;
        listPage.initializeSelectElement();
        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      }
    };
    xhr.open("PATCH", "/lists/favorites");
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({action: "add_favorite", currentAlbum: currentAlbum}));
  },
  addAlbumToNewList: function() {
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
  }
};
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

(function() {
  document.addEventListener('DOMContentLoaded', function() {
    listPage.initializeSelectElement();
    document.addEventListener("click", function(e) {
      listPage.closeToastsOnClick(e);
    }, {passive: true});

    var addToExistingListBtn = document.getElementById("add-to-list-btn");
    var addToNewListBtn = document.getElementById("add-to-new-list-btn");
    var newListNameInput = document.getElementById("new-list-name");

    addToExistingListBtn.addEventListener("click", listPage.addAlbumToExistingList);
    addToNewListBtn.addEventListener("click", listPage.addAlbumToNewList);
    newListNameInput.addEventListener("keyup", function(e) {
      if (e.keyCode === 13) { addToNewListBtn.click(); }
    }, {passive: true});
  }, {passive: true});
})();
