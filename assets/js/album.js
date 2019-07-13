// ====== START MATERIALIZE ======
// initialize tabs on card
document.addEventListener('DOMContentLoaded', function() {
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
      {}, window.location, window.location.origin + window.location.pathname
    );
  }
});

// initialize all floating action buttons
function initializeAllFAB() {
  var elems = document.querySelectorAll('.fixed-action-btn');
  window.FABinstances = M.FloatingActionButton.init(elems, {
    direction: "top",
    hoverEnabled: false
  });
  window.fabsInitialized = true;
}

// re-initialize destroyed FAB's when page is reached using browser "back" button
window.addEventListener('pageshow', function() {
  if (!window.fabsInitialized) { initializeAllFAB(); }
});

document.addEventListener('DOMContentLoaded', function() {
  initializeAllFAB();

  // slow down link to tags edit page to allow button animation to finish
  const editButtons = ["add-tags", "add-connections", "edit-connections", "add-lists", "edit-lists"];

  for (let i = 0; i < editButtons.length; i++) {
    const b = editButtons[i];

    document.getElementById(b).addEventListener("click", function(e) {
      e.preventDefault();
      // UI slowdown to match button collapse speed
      // const _this = this;
      // setTimeout(function() {
      //   return window.location = _this.href;
      // }, 75);

      for (let i = 0; i < window.FABinstances.length; i++) {
        const instance = window.FABinstances[i];
        instance.destroy();
        window.fabsInitialized = false;
      }
      return window.location = this.href;
    });
  }

  document.getElementById("search-tags").addEventListener("click", function(e) {
    e.preventDefault();
    if (selectedTags.length === 0) return M.toast({html: 'Select a tag to search by tags'});

    // UI slowdown to match button collapse speed
    // setTimeout(function() {
    //   return window.location = `/tags/search/${encodeURIComponent(selectedTags.join(",,"))}`;
    // }, 75);

    for (let i = 0; i < window.FABinstances.length; i++) {
      const instance = window.FABinstances[i];
      instance.destroy();
      window.fabsInitialized = false;
    }
    return window.location = `/tags/search/${encodeURIComponent(selectedTags.join(",,"))}`;
  });

  // close expanded fabs when user clicks somewhere not on the buttons
  document.addEventListener("click", function(e) {
    var clickedFAB = [
      "tags-fab-button", "show-all-tags", "show-my-tags", "add-tags",
      "connections-fab-button", "show-all-connections", "show-my-connections",
      "add-connections", "add-connections", "lists-fab-button", "show-all-lists",
      "show-my-lists", "add-lists", "edit-lists"
    ].includes(e.target.parentNode.id);

    if (!clickedFAB) {
      for (let i = 0; i < window.FABinstances.length; i++) {
        window.FABinstances[i].close();
      }
    }
  });

  // intentionally singular to match DOM classes
  contentTypes = ["tag", "connection", "list"];

  for (let i = 0; i < contentTypes.length; i++) {
    const contentType = contentTypes[i];

    toggleContentDisplayed(contentType);

    // all users fab button
    document.getElementById(`show-my-${contentType}s`).addEventListener("click", function() {
      localStorage.setItem(`${contentType}s`, "user");
      toggleContentDisplayed(contentType);
    });

    // all users tab icon
    document.getElementById(`all-${contentType}s-icon`).addEventListener("click", function() {
      localStorage.setItem(`${contentType}s`, "user");
      toggleContentDisplayed(contentType);
    });

    // user fab button
    document.getElementById(`show-all-${contentType}s`).addEventListener("click", function() {
      localStorage.setItem(`${contentType}s`, "all");
      toggleContentDisplayed(contentType);
    });

    // user tag icon
    document.getElementById(`user-${contentType}s-icon`).addEventListener("click", function() {
      localStorage.setItem(`${contentType}s`, "all");
      toggleContentDisplayed(contentType);
    });
  }

  // buttons are hidden by default to prevent flashing while page assets load
  showClass("fixed-action-btn");
});

// close toasts on click
document.addEventListener("click", function(e) {
  var parent = e.target.parentNode;
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

// refresh page if arriving on "back" action to make sure
// user login status is correctly reflected in the menu
if(performance.navigation.type == 2){
  location.reload(true);
}
// ====== END UTILITY FUNCTIONS ======

// ====== START SPINNER FUNCTIONALITY ======
const spinner = document.getElementById("album-cover-spinner-container");
function hideSpinner() {
  if (spinner.classList.contains("hide")) return;
  spinner.classList.add("hide");
}

function showSpinner() {
  spinner.classList.remove("hide");
}

if (!document.getElementById("page-album-cover").complete) {
  showSpinner();
}

document.getElementById("page-album-cover").addEventListener("load", function() {
  hideSpinner();
});
// ====== END SPINNER FUNCTIONALITY ======

let selectedTags = [];
addEventListenerToClass("tag", "click", function(e) {
  var toastOut = document.getElementById("toast-container");
  if (toastOut) { closeToast(); }

  e.target.classList.toggle("light-blue");
  e.target.classList.toggle("accent-4");
  e.target.classList.toggle("white-text");

  const value = e.target.dataset.value;
  const i = selectedTags.indexOf(value);
  return i === -1 ? selectedTags.push(value) : selectedTags.splice(i, 1);
});

function toggleContentDisplayed(contentType) {
  var tagDisplayPrefrence = localStorage.getItem(`${contentType}s`);
  if (!tagDisplayPrefrence) { localStorage.setItem(`${contentType}s`, "all"); }

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
}
