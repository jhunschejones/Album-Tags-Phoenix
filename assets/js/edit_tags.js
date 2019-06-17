document.addEventListener('DOMContentLoaded', function() {
  initializeChips();
});

function initializeChips() {
  var elems = document.querySelectorAll('.chips');
  window.instances = M.Chips.init(elems, {
    placeholder: 'Add your first tag...', // when there are no tags
    secondaryPlaceholder: 'Add another tag...', // when tags already exist
    data: currentTags.slice(0),
    onChipAdd: function(e, chip) {
      // `innerText` always ends with "close" when using materialize <i> element
      var tag = chip.innerText.substr(0, chip.innerText.lastIndexOf("close"));

      postNewTag(tag);
    },
    onChipDelete: function(e, chip) {
      // `innerText` always ends with "close" when using materialize <i> element
      var tag = chip.innerText.substr(0, chip.innerText.lastIndexOf("close"));
      var confirmed = confirm(`Are you sure you want to delete the '${tag}' tag? You cannot reverse this action.`);

      if (confirmed) {
        deleteTag(tag);
      } else {
        // reset chips to state before delete
        initializeChips();
      }
    }
  });
}

function postNewTag(tag) {
  console.log(tag);
  // remember to set window.instances[0].chipsData equal to new tag list 
  currentTags = window.instances[0].chipsData.slice(0)
}

function deleteTag(tag) {
  console.log(tag);
  // remember to set window.instances[0].chipsData equal to new tag list 
  currentTags = window.instances[0].chipsData.slice(0)
}
