var connectionsPage = {
  closeToast: function() {
    var toastElement = document.querySelector('.toast');
    var toastInstance = M.Toast.getInstance(toastElement);
    toastInstance.dismiss();
  },
  closeToastsOnClick: function(e) {
    var parent = e.target.parentNode;
    var isToast = (parent.classList && parent.classList.contains("toast")) || parent.id == "toast-container";
    if (isToast) {
      connectionsPage.closeToast();
    }
  },
  deleteConnection: function(parentAlbum, childAlbum) {
    var confirmed = confirm("Are you sure you want to delete this connection? You cannot undo this operation.");
    if (!confirmed) return;

    const currentAlbum = parseInt(
      window.location.pathname.replace("/connections/", "").replace("/edit", "")
    );

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== 4) return;

      if (xhr.status >= 200 && xhr.status < 300) {
        removeSelectedElement(`#connection-${childAlbum}`);
        M.toast({html: xhr.responseText.replace(/\"/g, "")});
      } else {
        M.toast({html: "Unable to delete connection"});
      }
    };
    xhr.open("DELETE", `/connections/${currentAlbum}`);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
    xhr.send(JSON.stringify({parentAlbum: parentAlbum, childAlbum: childAlbum}));
  }
};

(function() {
  document.addEventListener('DOMContentLoaded', function() {
    document.addEventListener("click", function(e) {
      connectionsPage.closeToastsOnClick(e);
    }, {passive: true});
  }, {passive: true});
})();
