var listPage = {
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
  deleteList: function(albumID, listID) {
    var confirmed = confirm("Are you sure you want to remove the album from this list? You cannot undo this operation.");
    if (!confirmed) return;

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        removeSelectedElement(`#list-${listID}`);
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
};

(function() {
  document.addEventListener('DOMContentLoaded', function() {
    document.addEventListener("click", function(e) {
      listPage.closeToastsOnClick(e);
    }, {passive: true});
  }, {passive: true});
})();
