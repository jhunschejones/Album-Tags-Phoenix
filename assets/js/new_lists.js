// ====== START UTILITY FUNCTIONS ======
function truncate(str, len){
  // set up the substring
  const subString = str.substr(0, len-1);
  // add elipse after last complete word & trim trailing comma
  return (subString.substr(0, subString.lastIndexOf(' ')).replace(/(^[,\s]+)|([,\s]+$)/g, '') + '...');
}
// ====== END UTILITY FUNCTIONS ======

// ====== START MATERIALIZE ======
// set up select from existing lists select/dropdown element
document.addEventListener('DOMContentLoaded', function() {
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
  })
}, {passive: true});
// ====== END MATERIALIZE ======

document.getElementById("add-to-list-btn").addEventListener("click", function() {
  var value = window.existingListSelect.getSelectedValues()[0];
  if (value === "") return;
  if (value === "favorites") return addToFavorites();

  console.log(`Adding list with value ${value}`)
}, {passive: true});

function addToFavorites() {
  console.log("Adding to favorites...")
}

document.getElementById("add-to-new-list-btn").addEventListener("click", function() {
  var newListName = document.getElementById("new-list-name").value.trim();
  console.log("New list: ", newListName);
}, {passive: true});

document.getElementById("new-list-name").addEventListener("keyup", function(e) {
  if (e.keyCode === 13) {
    document.getElementById("add-to-new-list-btn").click();
  }
});
