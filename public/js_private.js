/*
  General
*/
// Close info modal
const $closeInfoModal = document.getElementById("info-modal");
if ($closeInfoModal != null) {
  document.getElementById("info-modal").addEventListener('click', function () {
    document.getElementById("info-modal").classList.remove("is-active");
    document.documentElement.style.overflow = "auto";
  });
}

// Open info modal
function infoProductsModal(text) {
  var element = document.getElementById("info-modal");
  if (element != null) {
    element.classList.toggle("is-active");
    var content = document.getElementById("info-modal-content");
    content.innerHTML = text;
  }
}



/*
  Asset types
*/
// Close assets modal
const $closeAssetModal = document.getElementById("assetModal");
if ($closeAssetModal != null) {
  document.getElementById("assetModalClose").addEventListener('click', function () {
    document.getElementById("assetModal").classList.remove("is-active");
    document.documentElement.style.overflow = "auto";
  });
}

// Asset modal
const $assetEditRow = Array.prototype.slice.call(document.querySelectorAll('.editAsset'), 0);
if ($assetEditRow.length > 0) {
  $assetEditRow.forEach(el => {
    el.addEventListener('click', () => {

      var element = document.getElementById("assetModal")
      if (element != null) {
        element.classList.toggle("is-active");
      }

      var childs = el.querySelectorAll("td");
      document.getElementById("assetName").value = childs[1].innerText;
      document.getElementById("assetDescription").value = childs[2].innerText;

      if (childs[3].innerText == "true") {
        document.getElementById("strictno").checked = false;
        document.getElementById("strictyes").checked = true;
      } else {
        document.getElementById("strictno").checked = true;
        document.getElementById("strictyes").checked = false;
      }

      document.getElementById("assetForm").action = "/assetname/settings/types/update";

      document.getElementById("id").value = el.id;

    });
  });
}

// Open assets add modal
function assetAdd() {
  var element = document.getElementById("assetModal")
  element.classList.toggle("is-active");

  document.getElementById("assetName").value = "";
  document.getElementById("assetDescription").value = "";
  document.getElementById("strictno").checked = true;
  document.getElementById("strictyes").checked = false;

  document.getElementById("assetForm").action = "/assetname/settings/types/add";

  document.getElementById("id").value = "";
}



/*
  Asset O&M
*/
// Close assets modal
const $closeAssetOmModal = document.getElementById("assetOmModal");
if ($closeAssetOmModal != null) {
  document.getElementById("assetOmModalClose").addEventListener('click', function () {
    document.getElementById("assetOmModal").classList.remove("is-active");
    document.documentElement.style.overflow = "auto";
  });
}

// Asset modal
const $editAssetOm = Array.prototype.slice.call(document.querySelectorAll('.editAssetOm'), 0);
if ($editAssetOm.length > 0) {
  $editAssetOm.forEach(el => {
    el.addEventListener('click', () => {

      var element = document.getElementById("assetOmModal")
      if (element != null) {
        element.classList.toggle("is-active");
      }

      var childs = el.querySelectorAll("td");
      document.getElementById("assetOmDescription").value = childs[1].innerText;
      document.getElementById("assetOmInterval").value = childs[2].innerText;
      document.getElementById("assetOmDetails").value = childs[3].innerText;

      document.getElementById("assetOmForm").action = "/assetname/settings/omedit/update";

      document.getElementById("typeid").value = document.getElementById("asset").getAttribute("data-assetid");
      document.getElementById("id").value = el.id;
    });
  });
}

// Open assets add modal
function assetOmAdd() {
  var element = document.getElementById("assetOmModal")
  element.classList.toggle("is-active");

  document.getElementById("assetOmDescription").value = "";
  document.getElementById("assetOmInterval").value = "";
  document.getElementById("assetOmDetails").value = "";

  document.getElementById("assetOmForm").action = "/assetname/settings/omedit/add";

  document.getElementById("typeid").value = document.getElementById("asset").getAttribute("data-assetid");
  document.getElementById("id").value = "";
}



/*
  Asset documentation
*/
// Close assets modal
const $closeAssetDocModal = document.getElementById("assetDocModal");
if ($closeAssetDocModal != null) {
  document.getElementById("assetDocModalClose").addEventListener('click', function () {
    document.getElementById("assetDocModal").classList.remove("is-active");
    document.documentElement.style.overflow = "auto";
  });
}

// Asset modal
const $editAssetDoc = Array.prototype.slice.call(document.querySelectorAll('.editAssetDoc'), 0);
if ($editAssetDoc.length > 0) {
  $editAssetDoc.forEach(el => {
    el.addEventListener('click', () => {

      var element = document.getElementById("assetDocModal")
      if (element != null) {
        element.classList.toggle("is-active");
      }

      var childs = el.querySelectorAll("td");
      document.getElementById("responsecode").value = childs[1].innerText;
      document.getElementById("filetype").value     = childs[2].innerText;
      document.getElementById("viewtype").value     = childs[3].innerText;
      document.getElementById("designation").value  = childs[4].innerText;
      document.getElementById("runningid").value    = childs[5].innerText;
      document.getElementById("fileext").value      = childs[6].innerText;
      document.getElementById("description").value  = childs[7].innerText;

      document.getElementById("assetDocForm").action = "/assetname/settings/docedit/update";

      document.getElementById("typeid").value = document.getElementById("asset").getAttribute("data-assetid");
      document.getElementById("id").value = el.id;
    });
  });
}

// Open assets add modal
function assetDocAdd() {
  var element = document.getElementById("assetDocModal")
  element.classList.toggle("is-active");

  document.getElementById("responsecode").value = "";
  document.getElementById("filetype").value = "";
  document.getElementById("viewtype").value = "";
  document.getElementById("designation").value = "";
  document.getElementById("runningid").value = "01";
  document.getElementById("fileext").value = "";
  document.getElementById("description").value = "";

  document.getElementById("assetDocForm").action = "/assetname/settings/docedit/add";

  document.getElementById("typeid").value = document.getElementById("asset").getAttribute("data-assetid");
  document.getElementById("id").value = "";
}


/*
  Asset data
*/
// Assets modal
const $dataModal = document.getElementById("dataModal");
if ($dataModal != null) {
  document.getElementById("dataModalClose").addEventListener('click', function () {
    document.getElementById("dataModal").classList.remove("is-active");
    document.documentElement.style.overflow = "auto";
  });
  document.getElementById("dataModalCloseCross").addEventListener('click', function () {
    document.getElementById("dataModal").classList.remove("is-active");
    document.documentElement.style.overflow = "auto";
  });

  document.getElementById("idnrActivate").addEventListener('dblclick', function () {
    document.getElementById('idnr').disabled = false;
  });

}

/*// Checkbox (select asset)
const $checkbox = Array.prototype.slice.call(document.querySelectorAll('input[type=checkbox]'), 0);
if ($checkbox.length > 0) {
  $checkbox.forEach(el => {
    el.addEventListener('change', () => {
      event.preventDefault()
    });
  });
}*/


// Asset modal
const $editData = Array.prototype.slice.call(document.querySelectorAll(".editData td:not(.tagnr)"), 0);
if ($editData.length > 0) {
  $editData.forEach(elc => {
    elc.addEventListener('click', () => {
      var el = elc.parentNode;

      dataEditPreparation()

      if (assetCheckAnyOn()) {
        dataEditMany();
      } else {
        dataEditSingle(el);
      }

    });
  });
}


function dataEditPreparation() {
  var editMany = false;
  if (assetCheckAnyOn()) {
    editMany = true;
  }
  if (editMany) {
    document.getElementById("assetEditManyInfo").style.display = "block";
  } else {
    document.getElementById("assetEditManyInfo").style.display = "none";
  }

  assetFieldWarnOff();

  document.getElementById("customid").style.display = "block";
  document.getElementById("datefield").style.display = "block";
  document.getElementById("editedbyfield").style.display = "block";

  document.getElementById("assetNumber").style.display = "none";

  document.getElementById("idnr").disabled = true;
  document.getElementById("idnrLabelAdd").style.display = "none";
  document.getElementById("idnrLabelUpdate").style.display = "block";

  var element = document.getElementById("dataModal")
  if (element != null) {
    element.classList.toggle("is-active");
  }
}

function dataEditSelected() {
  var assets = assetCheckList();
  if (assets == "") {
    infoProductsModal("No assets is selected.<br>Select them by checking them in the tag-nr field.")
    return;
  }
  dataEditPreparation()
  dataEditMany();
}

function dataEditSingle(el) {
  console.log("Asset edit (single): " + el.id);

  var childs = el.querySelectorAll("td");
  document.getElementById("active").value = childs[2].innerText;
  document.getElementById("type").value = childs[4].innerText;//document.getElementById(el.id + "-typeid").value; //childs[3].innerText;
  document.getElementById("typesub").value = childs[5].innerText;
  document.getElementById("building").value = childs[6].innerText;
  document.getElementById("levelid").value = childs[7].innerText;

  document.getElementById("idnr").value = childs[8].innerText;
  document.getElementById("idnrOriginal").value = childs[8].innerText;

  document.getElementById("room").value = childs[9].innerText;
  document.getElementById("coordinates").value = childs[10].innerText;
  document.getElementById("description").value = childs[11].innerText;

  document.getElementById("date").value = childs[12].innerText;

  document.getElementById("reqname").value = childs[13].innerText;
  document.getElementById("reqemail").value = childs[14].innerText;
  document.getElementById("reqcompany").value = childs[15].innerText;

  document.getElementById("lastedit").value = childs[16].innerText;

  document.getElementById("project").value = childs[17].innerText;
  document.getElementById("projectid").value = childs[18].innerText;

  document.getElementById("dataForm").action = "/assetname/data/update";

  //document.getElementById("typeid").value = document.getElementById("asset").getAttribute("data-assetid");
  document.getElementById("id").value = el.id;

  document.getElementById("deleteData").href = "/assetname/data/delete?id=" + el.id;
}


function assetLoopIdIdentical(idlist, iden) {
  var ids = idlist.split(',');
  var check = "";
  for (var i = 0; i < ids.length; i++) {
    var tr = document.getElementById(ids[i]);
    var item = tr.querySelector("td." + iden).innerHTML
    if (check != "") {
      if (check != item) {
        //document.getElementById(iden).classList.remove("is-info");
        //document.getElementById(iden).classList.add("is-danger");
        assetFieldWarn(true, iden);
        return "falsi";
      }
    }
    check = item;
  }
  return check;
}
function assetLoopIdTagnr(idlist) {
  var ids = idlist.split(',');
  var check = "";
  for (var i = 0; i < ids.length; i++) {
    var tr = document.getElementById(ids[i]);
    var item = tr.querySelector("td.tagnr").textContent;
    check += "<br>- " + item;
  }
  return check;
}


function dataEditMany() {
  var idlist = assetCheckList();
  var diff = "";
  console.log("Asset edit (many): " + idlist);

  // Manually check active and type
  var active = assetLoopIdIdentical(idlist, "active");
  if (active == "falsi") {
    document.getElementById("activeSelect").classList.remove("is-info");
    document.getElementById("activeSelect").classList.add("is-danger");
    document.getElementById("active").value = "";
    diff += "<b>Active:</b> Is different across assets<br>"
  } else {
    document.getElementById("active").value = active;
  }

  var type = assetLoopIdIdentical(idlist, "type");
  if (type == "falsi") {
    document.getElementById("typeSelect").classList.remove("is-info");
    document.getElementById("typeSelect").classList.add("is-danger");
    document.getElementById("type").value = "";
    diff += "<b>Type:</b> Is different across assets<br>"
  } else {
    document.getElementById("typeRevert").value = type;
    var sel = document.getElementById("typeRevert");
    document.getElementById("type").value = sel[sel.selectedIndex].innerHTML;;
  }


  var items = "typesub,building,levelid,room,coordinates,description,reqname,reqemail,reqcompany,project,projectid".split(",");
  for (var i = 0; i < items.length; i++) {
    var item = assetLoopIdIdentical(idlist, items[i]);
    if (item == "falsi") {
      document.getElementById(items[i]).value = "";
      diff += "<b>" + capitalizeFirst(items[i]) + ":</b> Is different across assets<br>"
    } else {
      document.getElementById(items[i]).value = item;
    }
  }

  document.getElementById("customid").style.display = "none";
  document.getElementById("datefield").style.display = "none";
  document.getElementById("editedbyfield").style.display = "none";

  document.getElementById("dataForm").action = "/assetname/data/updatemany";

  document.getElementById("id").value = idlist;

  document.getElementById("deleteData").href = "/assetname/data/delete?id=" + idlist;


  document.getElementById("assetEditManyInfo").innerHTML = "<b>You are editing multiple assets at the same time. Editing anything now will be updated on all of these assets!</b><br>" + assetCheckList() + "<br><br>" + diff + "<br><b>This includes assets with ID:</b>" + assetLoopIdTagnr(idlist);
}


// Open assets add modal
function dataAdd() {
  //document.getElementById("datafield").style.display = "none";
  //document.getElementById("editedbyfield").style.display = "none";
  assetFieldWarnOff();

  document.getElementById("assetEditManyInfo").style.display = "none";

  document.getElementById("assetNumber").style.display = "block";
  document.getElementById("number").value = "1";

  document.getElementById("customid").style.display = "block";
  document.getElementById("datefield").style.display = "block";
  document.getElementById("editedbyfield").style.display = "block";

  document.getElementById("idnr").disabled = true;
  document.getElementById("idnrLabelAdd").style.display = "block";
  document.getElementById("idnrLabelUpdate").style.display = "none";

  var element = document.getElementById("dataModal")
  element.classList.toggle("is-active");

  document.getElementById("active").value = "Reserved";
  document.getElementById("type").value = document.getElementById("asset").getAttribute("data-assetid");
  document.getElementById("typesub").value = "";
  document.getElementById("building").value = document.getElementById("asset").getAttribute("data-building");
  document.getElementById("levelid").value = document.getElementById("asset").getAttribute("data-level");
  document.getElementById("idnr").value = "";
  document.getElementById("idnrOriginal").value = "";
  document.getElementById("room").value = "";
  document.getElementById("coordinates").value = "";
  document.getElementById("description").value = "";

  document.getElementById("reqname").value = "";
  document.getElementById("reqemail").value = "";
  document.getElementById("reqcompany").value = "";

  document.getElementById("project").value = "";
  document.getElementById("projectid").value = "";

  document.getElementById("dataForm").action = "/assetname/data/add";

 // document.getElementById("typeid").value = document.getElementById("asset").getAttribute("data-assetid");
  document.getElementById("id").value = "";
}

function assetCheckAnyOn() {
  var checkboxes = document.getElementsByClassName("check");
  for (var i = 0, n = checkboxes.length; i < n; i++) {
    if (checkboxes[i].checked == true) {
      return true;
    }
  }
  return false;
}
function assetCheckOn() {
  var checkboxes = document.getElementsByClassName("check");
  for (var i = 0, n = checkboxes.length; i < n; i++) {
    checkboxes[i].checked = true;
  }
}
function assetCheckOff() {
  var checkboxes = document.getElementsByClassName("check");
  for (var i = 0, n = checkboxes.length; i < n; i++) {
    checkboxes[i].checked = false;
  }
}
function assetCheckList() {
  var checkboxes = document.getElementsByClassName("check");
  var res = "";
  for (var i = 0, n = checkboxes.length; i < n; i++) {
    if (checkboxes[i].checked == true) {
      if (res != "") {
        res += ","
      }
      res += (checkboxes[i].getAttribute("data-assetid"));
    }
  }
  return res;
}
function assetExportXlsxSelected() {
  var assets = assetCheckList();
  if (assets == "") {
    infoProductsModal("No assets is selected.<br>Select them by checking them in the tag-nr field.")
    return;
  }
  var urlsort = document.getElementById("exportSelected").getAttribute("data-url");

  var url = "/assetname/data/show?export=selected&ids=" + assets + "&" + urlsort;

  window.location.href = url;
}


/*function assetWarnMarkHide() {
  var warn = document.querySelectorAll("span.warn");
  for (var i = 0, n = warn.length; i < n; i++) {
    warn[i].style.display = "none";
  }
}
function assetWarnMarkShow() {
  var warn = document.querySelectorAll("span.warn");
  for (var i = 0, n = warn.length; i < n; i++) {
    warn[i].style.display = "block";
  }
}*/

function assetFieldWarnOn() {
  var con = document.getElementById("dataForm");
  var inp = con.querySelectorAll(".item");
  for (var i = 0, n = inp.length; i < n; i++) {
    inp[i].classList.remove("is-info");
    inp[i].classList.add("is-danger");
  }
}
function assetFieldWarnOff() {
  var con = document.getElementById("dataForm");
  var inp = con.querySelectorAll(".item");
  for (var i = 0, n = inp.length; i < n; i++) {
    inp[i].classList.remove("is-danger");
    inp[i].classList.add("is-info");
  }
}
function assetFieldWarn(on, id) {
  var con = document.getElementById(id);
  //var inp = con.querySelector("." + item);
  if (on == true) {
    con.classList.add("is-danger");
    con.classList.remove("is-info");
  } else {
    con.classList.remove("is-danger");
    con.classList.add("is-info");
  }
}


function capitalizeFirst(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}