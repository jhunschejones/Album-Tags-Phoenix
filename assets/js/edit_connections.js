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

function deleteConnection(parentAlbum, childAlbum) {
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
