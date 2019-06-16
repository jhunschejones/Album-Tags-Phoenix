// ====== START MATERIALIZE ======
// initialize tabs on card
document.addEventListener('DOMContentLoaded', function() {
  var elems = document.querySelectorAll('.tabs');
  var instances = M.Tabs.init(elems, {
    // to enable swipable tabs, also add materialize carousel js and scss
    // swipeable: true
  });
});

// initialize floating action button
document.addEventListener('DOMContentLoaded', function() {
  var elems = document.querySelectorAll('.fixed-action-btn');
  var instances = M.FloatingActionButton.init(elems, {
    direction: "top",
    hoverEnabled: false
  });

  // close expanded fabs when user clicks outside
  document.addEventListener("click", function(e) {
    var clickedFAB = [
      "tags-fab-button", "show-all-tags", "show-my-tags", "add-tags",
      "connections-fab-button", "show-all-connections", "show-my-connections", "add-connections",
      "lists-fab-button", "show-all-lists", "show-my-lists", "add-lists",
    ].includes(e.target.parentNode.id);

    if (!clickedFAB) {
      for (let i = 0; i < instances.length; i++) {
        instances[i].close();
      }
    }
  });

  // intentionaly singular to match DOM classes
  contentTypes = ["tag", "connection", "list"];

  for (let i = 0; i < contentTypes.length; i++) {
    const contentType = contentTypes[i];

    toggleContentDisplayed(contentType);

    document.getElementById(`show-my-${contentType}s`).addEventListener("click", function() {
      localStorage.setItem(`${contentType}s`, "user");
      toggleContentDisplayed(contentType);
    });  
  
    document.getElementById(`show-all-${contentType}s`).addEventListener("click", function() {
      localStorage.setItem(`${contentType}s`, "all");
      toggleContentDisplayed(contentType);
    });
  }
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

let selectedTags = [];
addEventListenerToClass("tag", "click", function(e) {
  var toastOut = document.getElementById("toast-container");
  if (toastOut) { closeToast(); }

  e.target.classList.toggle("light-blue");
  e.target.classList.toggle("accent-4")
  e.target.classList.toggle("white-text");

  const value = e.target.dataset.value;
  const i = selectedTags.indexOf(value);
  return i === -1 ? selectedTags.push(value) : selectedTags.splice(i, 1);
});

document.getElementById("search-tags").addEventListener("click", function(e) {
  if (selectedTags.length === 0) {
    return M.toast({html: 'Select a tag to search by tags'});
  } else {
    console.log(selectedTags);
  }
});

function toggleContentDisplayed(contentType) {
  var tagDisplayPrefrence = localStorage.getItem(`${contentType}s`);
  if (!tagDisplayPrefrence) { localStorage.setItem(`${contentType}s`, "all"); }

  if (tagDisplayPrefrence == "user") {
    hideClass(contentType);
    showClass(`user-${contentType}`);
    document.getElementById(`show-my-${contentType}s`).classList.add("hide");
    document.getElementById(`show-all-${contentType}s`).classList.remove("hide");
  } else {
    showClass(contentType);
    document.getElementById(`show-my-${contentType}s`).classList.remove("hide");
    document.getElementById(`show-all-${contentType}s`).classList.add("hide");
  }
}

