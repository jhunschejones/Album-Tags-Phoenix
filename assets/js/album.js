(function() {
  var albumPage = {
    initializeAllFAB: function() {
      var elems = document.querySelectorAll('.fixed-action-btn');
      albumPage.FABinstances = M.FloatingActionButton.init(elems, {
        direction: "top",
        hoverEnabled: false
      });
      albumPage.fabsInitialized = true;
    },
    initlializeEditButtons: function() {
      var editButtons = ["add-tags", "add-connections", "edit-connections", "add-lists", "edit-lists"];
      var goToResourcePage = function(clickedButton) {
        for (let i = 0; i < albumPage.FABinstances.length; i++) {
          const instance = albumPage.FABinstances[i];
          instance.destroy();
          albumPage.fabsInitialized = false;
        }
        window.location = clickedButton.href;
      };

      for (let i = 0; i < editButtons.length; i++) {
        var editButton = document.getElementById(editButtons[i]);
        editButton.addEventListener("click", function(e) {
          e.preventDefault();
          goToResourcePage(this);
        });
      }
    },
    initializeCardTabs: function() {
      var elems = document.querySelectorAll('.tabs');
      var tabInstances = M.Tabs.init(elems, {
        // to enable swipable tabs, also add materialize carousel js and scss
        // swipeable: true
      });

      // go to card if one is indicated in the query parameter
      var card = new URLSearchParams(window.location.search).get("card");
      if (card) {
        document.getElementById(`go-to-${card}-card`).click();
        // then remove query param from url and history
        window.history.replaceState(
          {},
          window.location,
          window.location.origin + window.location.pathname
        );
      }
    },
    executeTagSearch: function() {
      if (albumPage.selectedTags.length === 0) {
        return M.toast({html: 'Select a tag to search by tags'});
      }

      for (let i = 0; i < albumPage.FABinstances.length; i++) {
        const instance = albumPage.FABinstances[i];
        instance.destroy();
        albumPage.fabsInitialized = false;
      }
      window.location = `/tags/search/${encodeURIComponent(albumPage.selectedTags.join(",,"))}`;
    },
    closeFabsWhenClickOutside: function(e) {
      var clickedFAB = [
        "tags-fab-button", "show-all-tags", "show-my-tags", "add-tags",
        "connections-fab-button", "show-all-connections", "show-my-connections",
        "add-connections", "add-connections", "lists-fab-button", "show-all-lists",
        "show-my-lists", "add-lists", "edit-lists"
      ].includes(e.target.parentNode.id);

      if (!clickedFAB) {
        for (let i = 0; i < albumPage.FABinstances.length; i++) {
          albumPage.FABinstances[i].close();
        }
      }
    },
    contentScopeButtonsClickable: function() {
      // intentionally singular to match DOM classes
      var contentTypes = ["tag", "connection", "list"];

      for (let i = 0; i < contentTypes.length; i++) {
        const contentType = contentTypes[i];

        albumPage.toggleContentDisplayed(contentType);

        // all users fab button
        document.getElementById(`show-my-${contentType}s`).addEventListener("click", function() {
          localStorage.setItem(`${contentType}s`, "user");
          albumPage.toggleContentDisplayed(contentType);
        });

        // all users icon on tabs
        document.getElementById(`all-${contentType}s-icon`).addEventListener("click", function() {
          localStorage.setItem(`${contentType}s`, "user");
          albumPage.toggleContentDisplayed(contentType);
        });

        // user fab button
        document.getElementById(`show-all-${contentType}s`).addEventListener("click", function() {
          localStorage.setItem(`${contentType}s`, "all");
          albumPage.toggleContentDisplayed(contentType);
        });

        // user icon on tabs
        document.getElementById(`user-${contentType}s-icon`).addEventListener("click", function() {
          localStorage.setItem(`${contentType}s`, "all");
          albumPage.toggleContentDisplayed(contentType);
        });
      }
      // buttons are hidden by default to prevent flashing while page assets load
      showClass("fixed-action-btn");
    },
    toggleContentDisplayed: function(contentType) {
      var tagDisplayPrefrence = localStorage.getItem(`${contentType}s`);
      if (!tagDisplayPrefrence) {
        localStorage.setItem(`${contentType}s`, "all");
      }

      if (tagDisplayPrefrence == "user") {
        hideClass(contentType);
        showClass(`user-${contentType}`);
        document.getElementById(`show-my-${contentType}s`).classList.add("hide");
        document.getElementById(`show-all-${contentType}s`).classList.remove("hide");
        document.getElementById(`user-${contentType}s-icon`).classList.remove("hide");
        document.getElementById(`all-${contentType}s-icon`).classList.add("hide");
      } else {
        showClass(contentType);
        document.getElementById(`show-my-${contentType}s`).classList.remove("hide");
        document.getElementById(`show-all-${contentType}s`).classList.add("hide");
        document.getElementById(`user-${contentType}s-icon`).classList.add("hide");
        document.getElementById(`all-${contentType}s-icon`).classList.remove("hide");
      }
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
        albumPage.closeToast();
      }
    },
    hideSpinner: function() {
      if (albumPage.spinner.classList.contains("hide")) {
        return;
      }
      albumPage.spinner.classList.add("hide");
    },
    showSpinner: function() {
      albumPage.spinner.classList.remove("hide");
    },
    selectTag: function(e) {
      var toastOut = document.getElementById("toast-container");
      if (toastOut) {
        albumPage.closeToast();
      }

      e.target.classList.toggle("light-blue");
      e.target.classList.toggle("accent-4");
      e.target.classList.toggle("white-text");

      var value = e.target.dataset.value;
      var tagIndex = albumPage.selectedTags.indexOf(value);

      if (tagIndex === -1) {
        albumPage.selectedTags.push(value);
      } else {
        albumPage.selectedTags.splice(tagIndex, 1);
      }
    },
    selectedTags: [],
  };

  document.addEventListener('DOMContentLoaded', function() {
    var tagSearchButton = document.getElementById("search-tags");
    albumPage.spinner = document.getElementById("album-cover-spinner-container");

    albumPage.initializeAllFAB();
    albumPage.initlializeEditButtons();
    albumPage.initializeCardTabs();
    albumPage.contentScopeButtonsClickable();

    document.addEventListener("click", function(e) {
      albumPage.closeFabsWhenClickOutside(e);
      albumPage.closeToastsOnClick(e);
    });
    tagSearchButton.addEventListener("click", function(e) {
      e.preventDefault();
      albumPage.executeTagSearch();
    });
    addEventListenerToClass("tag", "click", function(e) {
      albumPage.selectTag(e);
    });
  });

  // re-initialize destroyed FAB's when page is reached using browser "back" button
  window.addEventListener('pageshow', function() {
    if (!albumPage.fabsInitialized) {
      albumPage.initializeAllFAB();
    }
  });

  // refresh page if arriving on "back" action to make sure
  // user login status is correctly reflected in the menu
  if (performance.navigation.type == 2) {
    location.reload(true);
  }

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
  // ====== END UTILITY FUNCTIONS ======

  // ====== START SPINNER FUNCTIONALITY ======
  if (!document.getElementById("page-album-cover").complete) {
    albumPage.showSpinner();
  }

  document.getElementById("page-album-cover").addEventListener("load", function() {
    albumPage.hideSpinner();
  });
  // ====== END SPINNER FUNCTIONALITY ======
})();
