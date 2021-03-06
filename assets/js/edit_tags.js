(function(){
  var tagsPage = {
    closeToast: function() {
      var toastElement = document.querySelector('.toast');
      var toastInstance = M.Toast.getInstance(toastElement);
      toastInstance.dismiss();
    },
    closeToastsOnClick: function(e) {
      var parent = e.target.parentNode;
      var isToast = (parent.classList && parent.classList.contains("toast")) || parent.id == "toast-container";
      if (isToast) {
        tagsPage.closeToast();
      }
    },
    initializeChips: function() {
      var elems = document.querySelectorAll('.chips');
      tagsPage.chipsInstance = M.Chips.init(elems, {
        placeholder: 'Add your first tag...', // when there are no tags
        secondaryPlaceholder: 'Add another tag...', // when tags already exist
        data: currentTags.slice(0),
        onChipAdd: function(e, chip) {
          // `innerText` always ends with "close" when using materialize <i> element
          var tag = chip.innerText.substr(0, chip.innerText.lastIndexOf("close")).trim();

          tagsPage.postNewTag(tag);
        },
        onChipDelete: function(e, chip) {
          // `innerText` always ends with "close" when using materialize <i> element
          var tag = chip.innerText.substr(0, chip.innerText.lastIndexOf("close")).trim();
          var confirmed = confirm(`Are you sure you want to delete the '${tag}' tag? You cannot undo this operation.`);

          if (confirmed) {
            tagsPage.deleteTag(tag);
          } else {
            // reset chips to state before delete
            tagsPage.initializeChips();
          }
        }
      })[0];
    },
    postNewTag: function(tag) {
      const currentAlbum = parseInt(
        window.location.pathname.replace("/tags/", "").replace("/edit", "")
      );
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;

        if (xhr.status >= 200 && xhr.status < 300) {
          var tag_id = JSON.parse(xhr.responseText).tag_id;
          tagArray.push({tag_id: tag_id, text: tag});
          // remember to set tagsPage.chipsInstance.chipsData equal to new tag list
          currentTags = tagsPage.chipsInstance.chipsData.slice(0);
          tagsPage.tagInput.focus();
        } else {
          // display user message
          var message = JSON.parse(xhr.responseText).message;
          M.toast({html: message});
          // reset chips to previous state
          tagsPage.initializeChips();
          tagsPage.tagInput.focus();
        }
      };
      xhr.open("POST", "/tags");
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
      xhr.send(JSON.stringify({tag: tag, album: currentAlbum, customGenre: false}));
    },
    deleteTag: function(tag) {
      var tagID = tagArray.find(tagObject => tagObject.text === tag).tag_id;
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;

        if (xhr.status >= 200 && xhr.status < 300) {
          var tagIndex = tagArray.findIndex(tagObject => tagObject.text === tag);
          tagArray.splice(tagIndex, 1);
          // remember to set tagsPage.chipsInstance.chipsData equal to new tag list
          currentTags = tagsPage.chipsInstance.chipsData.slice(0);
          tagsPage.tagInput.focus();
        } else {
          M.toast({html: "Unable to delete tag"});
          tagsPage.tagInput.focus();
        }
      };
      xhr.open("DELETE", `/tags/${tagID}`);
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
      xhr.send(JSON.stringify({albumID: albumID}));
    }
  };

  document.addEventListener('DOMContentLoaded', function() {
    tagsPage.initializeChips();
    tagsPage.tagInput = document.getElementById("tag-input");
    tagsPage.tagInput.focus();

    document.addEventListener("click", function(e) {
      tagsPage.closeToastsOnClick(e);
    });
  });
})();
