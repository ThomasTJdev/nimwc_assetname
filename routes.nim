
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
      room: bool
      reqName: bool
      reqEmail: bool
      reqCompany: bool
      creator: bool
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

    let queryWhere = assetQuery(typeid, building, level, activeUsed, activeReserved, room, reqName, reqEmail, reqCompany, creator, @"asset", @"building", @"level", @"room", @"reqname", @"reqemail", @"reqcompany", @"creator")

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
        queryWhereSelected = "ad.id IN (" & @"ids" & ")"

      let (xlsxB, xlsxPath, xlsxFilename) = assetXlsx(db, queryWhereSelected, storageEFS / "assetname", "Sorted")

      if xlsxB:
        #sendFile(xlsxPath)
        asyncCheck deleteFileAsync(xlsxPath, 60 * 5)

        redirect("/assetname/data/download/" & xlsxFilename)

    let queryString = assetQueryData.format(queryWhere)
    let assets = getAllRows(db, sql(queryString))

    resp genMain(c, genAssetDataShow(db, assets, sort, @"asset", @"building", @"level", @"room", @"active", @"reqname", @"reqemail", @"reqcompany", @"creator"))


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

      if strictidnr == "true":
        if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND idnr = ?"), @"type", idnrFormat) != "":
          resp("Error - an asset already exists with: <br><br><div>Type: <br>Building: <br>IDnr: </div>")

      else:
        if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND building = ? AND level = ? AND idnr = ?"), @"type", @"building", @"level", idnrFormat) != "":
          resp("Error - an asset already exists with: <br><br><div>Type: <br>Building: <br>IDnr: </div>")

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
      resp("Error - an asset already exists with: 1")

    # Check if we're going to add multiple assets

    for i in countup(1, parseInt(@"number")):

      exec(db, sql("INSERT INTO asset_data (active, type, typesubname, building, level, idnr, room, coordinates, description, reqName, reqEmail, reqCompany, creator, project, projectid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"), @"active", @"type", @"typesub", @"building", @"level", idnrNext, @"room", @"coordinates", @"description", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid")

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
        # Update data
        exec(db, sql("UPDATE asset_data SET active = ?, type = ?, typesubname = ?, building = ?, level = ?, room = ?, coordinates = ?, description = ?, reqName = ?, reqEmail = ?, reqCompany = ?, modifiedby = ?, project = ?, projectid = ? WHERE id = ?;"), @"active", @"type", @"typesub", @"building", @"level", @"room", @"coordinates", @"description", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid", id)

    elif request.path == "/assetname/data/update":
      var idnrCurrent = getValue(db, sql("SELECT idnr FROM asset_data WHERE id = ?;"), @"id")
      if @"idnr" != "" and @"idnr" != idnrCurrent:
        # Format IDnr
        idnrCurrent = assetIdFormat(@"idnr")
        if idnrCurrent == "":
          resp("Something went wrong when formatting the running number")
      
      # Check if asset requires a unique running id
      let strictidnr = getValue(db, sql("SELECT strictidnr FROM asset_types WHERE id = ?;"), @"type")
      # Check for duplicated
      if strictidnr == "true":
        if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND idnr = ? AND id IS NOT ?;"), @"type", idnrCurrent, @"id") != "":
          resp("Error - asset already exists")

      else:
        if getValue(db, sql("SELECT id FROM asset_data WHERE building = ? AND type = ? AND level = ? AND idnr = ? AND id IS NOT ?;"), @"building", @"type", @"level", idnrCurrent, @"id") != "":
          resp("Error - asset already exists")

      # Update running
      if @"idnr" != "" and @"idnr" != idnrCurrent:
        # Update new ID
        exec(db, sql("UPDATE asset_data SET idnr = ? WHERE id = ?;"), @"id")

      # Update data
      exec(db, sql("UPDATE asset_data SET active = ?, type = ?, typesubname = ?, building = ?, level = ?, room = ?, coordinates = ?, description = ?, reqName = ?, reqEmail = ?, reqCompany = ?, modifiedby = ?, project = ?, projectid = ? WHERE id = ?;"), @"active", @"type", @"typesub", @"building", @"level", @"room", @"coordinates", @"description", @"reqname", @"reqemail", @"reqcompany", c.userid, @"project", @"projectid", @"id")


    redirect("/assetname/data/show?" & @"urlsort")


  get "/assetname/data/delete":
    createTFD()
    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      redirect("/")

    exec(db, sql("DELETE FROM asset_data WHERE id = ?"), @"id")

    redirect("/assetname/data/show?" & @"urlsort")