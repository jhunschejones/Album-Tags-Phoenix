// ====== START UTILITY FUNCTIONS ======
function removeSelectedElement(selector) {
  if (selector[0] === ".") {
    const c = document.querySelectorAll(selector);
    for (let i = 0; i < c.length; i++) {
      c[i].parentNode.removeChild(c[i]);
    }
  } else if (selector[0] === "#") {
    const e = document.getElementById(selector.substring(1));
    if (e) { e.parentNode.removeChild(e); }
  } else {
    console.error("removeSelectedElement() was passed an invalid selector");
  }
}
// ====== END UTILITY FUNCTIONS ======

// ====== START MATERIALIZE ======
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

function deleteList(albumID, listID) {
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
