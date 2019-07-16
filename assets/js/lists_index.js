// ====== START MATERIALIZE ======
// initialize floating action button
document.addEventListener('DOMContentLoaded', function() {
  var elems = document.querySelectorAll('.fixed-action-btn');
  var instances = M.FloatingActionButton.init(elems, {
    direction: "top",
    hoverEnabled: false
  });

  // close expanded fabs when user clicks somewhere not on the buttons
  document.addEventListener("click", function(e) {
    var clickedFAB = [
      "lists-fab-button", "add-lists", "edit-lists"
    ].includes(e.target.parentNode.id);

    if (!clickedFAB) {
      for (let i = 0; i < instances.length; i++) {
        instances[i].close();
      }
    }
  });
});

// initialize modal
document.addEventListener('DOMContentLoaded', function() {
  var newListModal = document.getElementById("new-list-modal");
  window.newListModal = M.Modal.init(newListModal, {
    onOpenEnd: function() {
      // focus on input when modal is launched
      document.getElementById("list-name-input").focus();
  }});

  document.getElementById("add-lists").addEventListener("click", function() {
    window.newListModal.open();
  });
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

// ====== START UTILITIES ======
window.editLists = false;
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
// ====== END UTILITIES ======
document.getElementById("edit-lists").addEventListener("click", function() {
  if (!window.editLists) {
    window.editLists = true;
    showClass("delete-button");
  } else {
    window.editLists = false;
    hideClass("delete-button");
  }
});

document.getElementById("list-name-input").addEventListener("keydown", function(e) {
  if(e.keyCode == 13) {
    createNewList();
  }
});

function createNewList() {
  var newListName = document.getElementById("list-name-input").value.trim();
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState !== 4) return;

    if (xhr.status >= 200 && xhr.status < 300) {
      document.getElementById("list-name-input").value = "";
      M.toast({html: JSON.parse(xhr.responseText).message});
      addListtCardToUI(JSON.parse(xhr.responseText).new_list);
      window.newListModal.close();
    } else {
      M.toast({html: xhr.responseText.replace(/\"/g, "")});
    }
  };
  xhr.open("POST", "/lists");
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
  xhr.send(JSON.stringify({
    private: false,
    title: newListName
  }));
}

function deleteList(listID) {
  var confirmed = confirm("Are you sure you want to delete this list? You cannot undo this operation.");
  if (!confirmed) return;

  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState !== 4) return;

    if (xhr.status >= 200 && xhr.status < 300) {
      removeSelectedElement(`#list-${listID}`);
      removeSelectedElement("#my-favorites-list");
      M.toast({html: xhr.responseText.replace(/\"/g, "")});
    } else {
      M.toast({html: "Unable to delete list"});
    }
  };
  xhr.open("DELETE", `/lists/${listID}`);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader("X-CSRF-Token", CSRF_TOKEN);
  xhr.send();
}

function addListtCardToUI(listInfo) {
  document.getElementById("lists-row").appendChild(
    stringToNode(
      `<div id="list-${listInfo.id}">
        <div class="delete-button hide " onclick="deleteList(${listInfo.id})">
          &#10005;
        </div>
        <div class="list">
          <a href="/lists/${listInfo.id}">
            <div class="row">
              <div class="col"><img class="responsive-img" src=""></div>
              <div class="col"><img class="responsive-img" src=""></div>
            </div>
            <div class="row">
              <div class="col"><img class="responsive-img" src=""></div>
              <div class="col"><img class="responsive-img" src=""></div>
            </div>
            <div class="list-title">${listInfo.title}</div>
          </a>
        </div>
      </div>`
    )
  );
}
