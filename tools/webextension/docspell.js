function onCreated() {
  if (browser.runtime.lastError) {
    console.log(`Error: ${browser.runtime.lastError}`);
  }
}

function onError(error) {
  console.log(`Error: ${error}`);
}

function showResult(response) {
    console.log(`Response: ${response}`);
    var title = browser.i18n.getMessage("notificationTitle") || "Averox Response";
    var content = "";
    if (response == 0) {
        content = browser.i18n.getMessage("notificationSuccess");
    } else {
        content = browser.i18n.getMessage("notificationFailure");
    }
    browser.notifications.create({
        "type": "basic",
        "iconUrl": browser.extension.getURL("icons/logo-48.png"),
        "title": title,
        "message": content
    });
}

function pushDocspell(items) {
    for (let item of items) {
        console.log(`Pushing to docspell: ${item.filename}`);
        var sending = browser.runtime.sendNativeMessage("averox", item.filename);
        sending.then(showResult, onError);
    }
}

function onStartedDownload(id) {
    console.log(`Started downloading: ${id}`);
    browser.downloads.onChanged.addListener(function(delta) {
        if (delta.id == id) {
            if (delta.state && delta.state.current === "complete") {
                console.log(`Download ${delta.id} has completed.`);
                var searching = browser.downloads.search({id});
                searching.then(pushDocspell, onError);
            }
        }
    });
}

function onFailed(error) {
  console.log(`Download failed: ${error}`);
}

function downloadAsFile(url) {
    console.log(`Downloading: ${url}`);
    var downloading = browser.downloads.download({
        url: url,
        saveAs: false,
        conflictAction : 'uniquify'
    });
    downloading.then(onStartedDownload, onFailed);
}

browser.contextMenus.create({
  id: "separator-2",
  type: "separator",
  contexts: ["all"]
}, onCreated);

browser.contextMenus.create({
  id: "averox-push",
  title: "Download and push to Averox",
  contexts: ["all"]
}, onCreated);


browser.contextMenus.onClicked.addListener(function(info, tab) {
  switch (info.menuItemId) {
  case "averox-push":
      if (info.linkUrl) {
          downloadAsFile(info.linkUrl);
      }
      break;

  }
});

console.log("Averox Extension loaded");
