
  #[
    Settings admin: Pages
  ]#
  get "/assetname":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/login")

    resp genMain(c, genAsset(db))


  get "/assetname/settings":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/login")

    resp genMain(c, genAssetSettings(db))


  get "/assetname/settings/types":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/login")

    resp genMain(c, genAssetSettingsTypes(db))


  get "/assetname/settings/documentation":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/login")

    resp genMain(c, genAssetSettingsTypesChoose(db, "documentation"))
    #resp genMain(c, genAssetSettingsDocumentation(db))

  get "/assetname/settings/documentation/@id":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/login")

    resp genMain(c, genAssetSettingsDocumentation(db, @"id"))
    #resp genMain(c, genAssetSettingsDocumentation(db))


  get "/assetname/settings/om":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/login")

    resp genMain(c, genAssetSettingsTypesChoose(db, "O&M"))
    #resp genMain(c, genAssetSettingsOm(db))


  get "/assetname/settings/om/@id":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/login")

    resp genMain(c, genAssetSettingsOm(db, @"id"))



  #[
    Settings: Asset types
  ]#
  post "/assetname/settings/types/add":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    if @"name" == "" or getValue(db, sql("SELECT name FROM asset_types WHERE name = ?;"), @"name") != "":
      redirect("/assetname/settings/types")

    let strictidnr = if @"strictidnr" == "strictyes": "true" else: "false"

    exec(db, sql("INSERT INTO asset_types (name, description, strictidnr) VALUES (?, ?, ?);"), @"name", @"description", strictidnr)

    redirect("/assetname/settings/types")


  post "/assetname/settings/types/update":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    if @"name" == "" or getValue(db, sql("SELECT name FROM asset_types WHERE name = ? AND id != ?;"), @"name", @"id") != "":
      redirect("/assetname/settings/types")

    let strictidnr = if @"strictidnr" == "strictyes": "true" else: "false"

    exec(db, sql("UPDATE asset_types SET name = ?, description = ?, strictidnr = ? WHERE id = ?;"), @"name", @"description", strictidnr, @"id")

    redirect("/assetname/settings/types")


  #[
    Settings: Asset O&M
  ]#
  post "/assetname/settings/omedit/add":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator] or @"typeid" == "":
      redirect("/")

    let interval = if isDigit(@"interval"): @"interval" else: "0"

    exec(db, sql("INSERT INTO asset_om (type, description, details, interval) VALUES (?, ?, ?, ?);"), @"typeid", @"description", @"details", interval)

    redirect("/assetname/settings/om/" & @"typeid")


  post "/assetname/settings/omedit/update":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator] or @"id" == "" or @"typeid" == "":
      redirect("/")

    let interval = if isDigit(@"interval"): @"interval" else: "0"

    exec(db, sql("UPDATE asset_om SET description = ?, details = ?, interval = ? WHERE id = ?;"), @"description", @"details", interval, @"id")

    redirect("/assetname/settings/om/" & @"typeid")


  #[
    Settings: Asset documentation
  ]#
  post "/assetname/settings/docedit/add":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator] or @"typeid" == "":
      redirect("/")


    exec(db, sql("INSERT INTO asset_documentation (type, responsecode, filetype, viewtype, designation, runningid, fileext, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"), @"typeid", @"responsecode", @"filetype", @"viewtype", @"designation", @"runningid", @"fileext", @"description")

    redirect("/assetname/settings/documentation/" & @"typeid")


  post "/assetname/settings/docedit/update":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator] or @"id" == "" or @"typeid" == "":
      redirect("/")

    exec(db, sql("UPDATE asset_documentation SET responsecode = ?, filetype = ?, viewtype = ?, designation = ?, runningid = ?, fileext = ?, description = ? WHERE id = ?;"), @"responsecode", @"filetype", @"viewtype", @"designation", @"runningid", @"fileext", @"description", @"id")

    redirect("/assetname/settings/documentation/" & @"typeid")


  #[
    Settings: Asset data
  ]#
  get "/assetname/data":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/login")

    resp genMain(c, genAssetData(db))


  get "/assetname/data/show":
    createTFD()
    if not c.loggedIn:
      redirect("/login")

    var
      typeid: bool
      building: bool
      level: bool
      activeUsed: bool
      activeReserved: bool
      activeRemoved: bool
      room: bool
      reqName: bool
      reqEmail: bool
      reqCompany: bool
      creator: bool
      supplier: bool
      oldtag: bool
      sort: string

    if @"asset" != "":
      if sort != "": sort.add("&")
      sort.add("asset=" & @"asset")
      typeid = true

    if @"building" != "":
      if sort != "": sort.add("&")
      sort.add("building=" & @"building")
      building = true

    if @"level" != "":
      if sort != "": sort.add("&")
      sort.add("level=" & @"level")
      level = true

    if @"active" != "":
      if @"active" == "Reserved":
        if sort != "": sort.add("&")
        sort.add("active=" & @"active")
        activeReserved = true
      elif @"active" == "Used":
        if sort != "": sort.add("&")
        sort.add("active=" & @"active")
        activeUsed = true
      elif @"active" == "Removed":
        if sort != "": sort.add("&")
        sort.add("active=" & @"active")
        activeRemoved = true

    if @"room" != "":
      if sort != "": sort.add("&")
      sort.add("room=" & @"room")
      room = true

    if @"reqname" != "":
      if sort != "": sort.add("&")
      sort.add("reqname=" & @"reqname")
      reqName = true

    if @"reqemail" != "":
      if sort != "": sort.add("&")
      sort.add("reqemail=" & @"reqemail")
      reqEmail = true

    if @"reqcompany" != "":
      if sort != "": sort.add("&")
      sort.add("reqcompany=" & @"reqcompany")
      reqCompany = true

    if @"creator" != "":
      if sort != "": sort.add("&")
      sort.add("creator=" & @"creator")
      creator = true

    if @"supplier" != "":
      if sort != "": sort.add("&")
      sort.add("supplier=" & @"supplier")
      supplier = true

    if @"oldtag" != "":
      if sort != "": sort.add("&")
      sort.add("oldtag=" & @"oldtag")
      oldtag = true

    let queryWhere = assetQuery(typeid, building, level, activeUsed, activeReserved, activeRemoved, room, reqName, reqEmail, reqCompany, creator, supplier, oldtag, @"asset", @"building", @"level", @"room", @"reqname", @"reqemail", @"reqcompany", @"creator", @"supplier", @"oldtag")

    if @"export" == "all":
      let (xlsxB, xlsxPath, xlsxFilename) = assetXlsx(db, "", storageEFS / "assetname", "All")

      if xlsxB:
        #sendFile(xlsxPath)
        asyncCheck deleteFileAsync(xlsxPath, 60 * 5)

        redirect("/assetname/data/download/" & xlsxFilename)

    elif @"export" == "sort":
      let (xlsxB, xlsxPath, xlsxFilename) = assetXlsx(db, queryWhere, storageEFS / "assetname", "Sorted")

      if xlsxB:
        #sendFile(xlsxPath)
        asyncCheck deleteFileAsync(xlsxPath, 60 * 5)

        redirect("/assetname/data/download/" & xlsxFilename)

    elif @"export" == "selected":
      var queryWhereSelected: string
      if queryWhere != "":
        queryWhereSelected = queryWhere & " AND ad.id IN (" & @"ids" & ")"
      else:
        queryWhereSelected = " WHERE ad.id IN (" & @"ids" & ")"

      let (xlsxB, xlsxPath, xlsxFilename) = assetXlsx(db, queryWhereSelected, storageEFS / "assetname", "Sorted")

      if xlsxB:
        #sendFile(xlsxPath)
        asyncCheck deleteFileAsync(xlsxPath, 60 * 5)

        redirect("/assetname/data/download/" & xlsxFilename)

    var queryOrder: string
    if @"dbsort" != "" and @"dbsort" in ["id", "type", "active", "typesub", "building", "levelid", "idnr", "room", "coordinates", "description", "modified", "reqname", "reqemail", "reqcompany", "lastedit", "project", "projectid", "supplier", "oldtag"]:
      var dbSort: string
      case @"dbsort"
      of "levelid":
        dbSort = "ad.level"
      of "typeid":
        dbSort = "ad.type"
      of "type":
        dbSort = "at.name"
      of "typesub":
        dbSort = "ad.typesubname"
      of "lastedit":
        dbSort = "pm.name"
      of "reqname":
        dbSort = "ad.reqName"
      of "reqEmail":
        dbSort = "ad.reqEmail"
      of "reqCompany":
        dbSort = "ad.reqCompany"
      else:
        dbSort = "ad." & @"dbsort"

      if @"ascdesc" in ["ASC", "DESC"]:
        queryOrder = " ORDER BY " & dbSort & " " & @"ascdesc"
      else:
        queryOrder = " ORDER BY " & dbSort
    else:
      queryOrder = " ORDER BY ad.building, at.name, ad.level, ad.idnr"

    let queryString = assetQueryData.format(queryWhere, queryOrder)
    let assets = getAllRows(db, sql(queryString))

    resp genMain(c, genAssetDataShow(db, assets, sort, @"asset", @"building", @"level", @"room", @"active", @"reqname", @"reqemail", @"reqcompany", @"creator", @"supplier", @"oldtag", @"dbsort", @"ascdesc"))


  get "/assetname/data/download/@filename":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    sendFile(storageEFS / "assetname" / decodeUrl(@"filename", false))


  post "/assetname/data/add":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    # Check required data
    if @"type" == "" or @"building" == "" or @"level" == "":
      resp("Error - missing required data")

    # Check number
    if not isDigit(@"number"):
      resp("Error - specify the number of assets")

    # Check if asset requires a unique running id
    let strictidnr = getValue(db, sql("SELECT strictidnr FROM asset_types WHERE id = ?;"), @"type")

    # Check for duplicates - only relevant if idnr is specified
    # Add manually based on idnr
    if @"idnr" != "":
      let idnrFormat = assetIdFormat(@"idnr")

      if not assetCheckDuplicatesAdd(db, @"type", @"building", @"level", idnrFormat):
        resp("Error - an asset already exists with: <br><br><div>Type: <br>Building: <br>IDnr: </div>")

      #if strictidnr == "true":
      #  if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND idnr = ?"), @"type", idnrFormat) != "":
      #    resp("Error - an asset already exists with: <br><br><div>Type: <br>Building: <br>IDnr: </div>")

      #else:
      #  if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND building = ? AND level = ? AND idnr = ?"), @"type", @"building", @"level", idnrFormat) != "":
      #    resp("Error - an asset already exists with: <br><br><div>Type: <br>Building: <br>IDnr: </div>")

    # Get running number
    var idnrNext: string
    if @"idnr" != "":
      # Okay, we'll manully add 1 asset
      idnrNext = assetIdFormat(@"idnr")

    else:
      idnrNext = assetNextIdFind(db, @"type", @"building", @"level", strictidnr)

    if idnrNext == "":
      resp("Something went wrong when formatting the running number")

    # Check again for duplicated
    if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND building = ? AND level = ? AND idnr = ?"), @"type", @"building", @"level", idnrNext) != "":
      resp("Error - an asset already exists with: " & idnrNext)

    # Check if we're going to add multiple assets

    for i in countup(1, parseInt(@"number")):
      var assetData: AssetData
      assetData.active      = @"active"
      assetData.assettype   = ""
      assetData.assettypeid = @"type"
      assetData.typesubname = @"typesub"
      assetData.building    = @"building"
      assetData.level       = @"level"
      assetData.idnr        = idnrNext
      assetData.room        = @"room"
      assetData.coordinates = @"coordinates"
      assetData.description = @"description"
      assetData.supplier    = @"supplier"
      assetData.oldtag      = @"oldtag"
      assetData.reqName     = @"reqname"
      assetData.reqEmail    = @"reqemail"
      assetData.reqCompany  = @"reqcompany"
      assetData.creator     = c.userid
      assetData.project     = @"project"
      assetData.projectid   = @"projectid"

      assetAdd(db, @"active", @"type", @"typesub", @"building", @"level", idnrNext, @"room", @"coordinates", @"description", @"supplier", @"oldtag", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid")
      #exec(db, sql("INSERT INTO asset_data (active, type, typesubname, building, level, idnr, room, coordinates, description, reqName, reqEmail, reqCompany, creator, project, projectid, supplier, oldtag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"), @"active", @"type", @"typesub", @"building", @"level", idnrNext, @"room", @"coordinates", @"description", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid", @"supplier", @"oldtag")

      idnrNext = assetNextIdCalc(idnrNext)

    redirect("/assetname/data/show?" & @"urlsort")


  post re"/assetname/data/(update|updatemany)":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    # Check required data
    if @"type" == "" or @"building" == "" or @"level" == "":
      resp("Error - missing required data: Building, Level or Assettype")

    # Check if running number has been changed
    if request.path == "/assetname/data/updatemany":
      for id in split(@"id", ","):
        # Check duplicated
        let idnrCurrent = getValue(db, sql("SELECT idnr FROM asset_data WHERE id = ?;"), id)
        if not assetCheckDuplicatesUpdate(db, @"type", @"building", @"level", idnrCurrent, id):
          resp("Error - asset already exists")

        # Update data
        assetUpdate(db, @"active", @"type", @"typesub", @"building", @"level", @"room", @"coordinates", @"description", @"supplier", @"oldtag", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid", id)
        #exec(db, sql("UPDATE asset_data SET active = ?, type = ?, typesubname = ?, building = ?, level = ?, room = ?, coordinates = ?, description = ?, reqName = ?, reqEmail = ?, reqCompany = ?, modifiedby = ?, project = ?, projectid = ?, supplier = ?, oldtag = ? WHERE id = ?;"), @"active", @"type", @"typesub", @"building", @"level", @"room", @"coordinates", @"description", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid", @"supplier", @"oldtag", id)

    elif request.path == "/assetname/data/update":
      var idnrCurrent = getValue(db, sql("SELECT idnr FROM asset_data WHERE id = ?;"), @"id")
      if @"idnr" != "" and @"idnr" != idnrCurrent:
        # Format IDnr
        idnrCurrent = assetIdFormat(@"idnr")
        if idnrCurrent == "":
          resp("Something went wrong when formatting the running number")

      # Check if asset requires a unique running id
      if not assetCheckDuplicatesUpdate(db, @"type", @"building", @"level", idnrCurrent, @"id"):
        resp("Error - asset already exists")
      #let strictidnr = getValue(db, sql("SELECT strictidnr FROM asset_types WHERE id = ?;"), @"type")
      # Check for duplicated
      #if strictidnr == "true":
      #  if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND idnr = ? AND id IS NOT ?;"), @"type", idnrCurrent, @"id") != "":
      #    resp("Error - asset already exists")
      #else:
      #  if getValue(db, sql("SELECT id FROM asset_data WHERE building = ? AND type = ? AND level = ? AND idnr = ? AND id IS NOT ?;"), @"building", @"type", @"level", idnrCurrent, @"id") != "":
      #    resp("Error - asset already exists")

      # Update running
      if @"idnr" != "" and @"idnr" != idnrCurrent:
        # Update new ID
        exec(db, sql("UPDATE asset_data SET idnr = ? WHERE id = ?;"), @"id")

      # Update data
      assetUpdate(db, @"active", @"type", @"typesub", @"building", @"level", @"room", @"coordinates", @"description", @"supplier", @"oldtag", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid", @"id")
      #exec(db, sql("UPDATE asset_data SET active = ?, type = ?, typesubname = ?, building = ?, level = ?, room = ?, coordinates = ?, description = ?, reqName = ?, reqEmail = ?, reqCompany = ?, modifiedby = ?, project = ?, projectid = ?, supplier = ?, oldtag = ? WHERE id = ?;"), @"active", @"type", @"typesub", @"building", @"level", @"room", @"coordinates", @"description", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid", @"supplier", @"oldtag", @"id")


    redirect("/assetname/data/show?" & @"urlsort")


  get "/assetname/data/delete":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    for id in split(@"id", ","):
      exec(db, sql("DELETE FROM asset_data WHERE id = ?"), id)

    redirect("/assetname/data/show?" & @"urlsort")



  #[
    Settings: Import
  ]#

  get "/assetname/import":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    resp genMain(c, genAssetImport(db))


  post re"/assetname/import/(new|update)":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    let path = storageEFS / "assetname" / randomStringAlpha(10) & ".xlsx"
    if fileExists(path):
      resp("An error occurred (intern filepath exists)")

    try:
      writeFile(path, request.formData.getOrDefault("file").body)
    except:
      resp("An error occurred")

    if fileExists(path):
      var xlsxData: SheetTable
      try:
        xlsxData = parseExcel(path)
      except:
        resp("Internal parsing error of XLSX file")

      var
        xlsxBool: bool
        xlsxRes: string

      case request.path
      of "/assetname/import/new":
        (xlsxBool, xlsxRes) = assetImportXlsx(db, c.userid, $c.rank, xlsxData, false)
      of "/assetname/import/update":
        (xlsxBool, xlsxRes) = assetImportXlsx(db, c.userid, $c.rank, xlsxData, true)
      else:
        resp("ERROR")

      discard tryRemoveFile(path)

      debug(xlsxRes)

      if xlsxBool:
        let message = xlsxRes
        resp genMain(c, genAssetImport(db, message))

      resp(xlsxRes)