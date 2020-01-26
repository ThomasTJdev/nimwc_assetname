# Copyright 2020 - Thomas T. Jarløv

import strutils, db_sqlite, xlsx, logging

import assetData, assetTypes


proc assetImportXlsx*(db: DbConn, userID, userRank: string, xlsxData: SheetTable, updateExisting=false): (bool, string) =
  ## Imports or Updates asset from XLSX data

  let rows = xlsxData["Assets"].toSeq(false)

  if rows.len() > 5000:
    error("assetImportXlsx(): Trying to import more than 5.000 tasks")
    return (false, "Trying to import more than 5.000 tasks")

  elif rows.len() == 0:
    error("assetImportXlsx(): No rows found")
    return (false, "No data was found. Is your sheet named 'Assets'?")

  var
    counter: int
    headingReached: bool
    updatedNotFound: string

  for row in rows:
    # Loop until heading is reached
    if not headingReached:
      if row[0] == "ID": headingReached = true
      continue

    if row[3] == "":
      continue

    # Create type
    var assetData: AssetData

    # Only use DB id when updating
    if updateExisting:
      assetData.id = row[0]

    # Custom tag nr. is row[1]

    assetData.active      = row[2]
    assetData.assettype   = row[3]
    assetData.typesubname = row[4]
    assetData.building    = row[5]
    assetData.level       = row[6]
    assetData.idnr        = row[7]
    assetData.room        = row[8]
    assetData.coordinates = row[9]
    assetData.description = row[10]
    assetData.supplier    = row[11]
    assetData.oldtag      = row[12]
    assetData.reqName     = row[13]
    assetData.reqEmail    = row[14]
    assetData.reqCompany  = row[15]
    assetData.project     = row[16]
    assetData.projectid   = row[17]

    assetData.assettypeid = getValue(db, sql("SELECT id FROM asset_types WHERE name = ?;"), assetData.assettype)

    if assetData.building == "":
      return (false, "Error - building not specified for: " & $row)
    elif assetData.assettype == "" or assetData.assettypeid == "":
      return (false, "Error - type not specified for: " & $row)
    elif assetData.level == "":
      return (false, "Error - level not specified for: " & $row)

    # Update asset:
    if updateExisting:
      let idnrCurrent = getValue(db, sql("SELECT idnr FROM asset_data WHERE id = ?;"), assetData.id)
      if idnrCurrent == "":
        updatedNotFound.add("<br>" & $row)
        continue

      if not assetCheckDuplicatesUpdate(db, assetData.assettypeid, assetData.building, assetData.level, idnrCurrent, assetData.id):
        return (false, "Duplicate found in row: " & $row)

      assetUpdate(db, assetData.active, assetData.assettypeid, assetData.typesubname, assetData.building, assetData.level, assetData.room, assetData.coordinates, assetData.description, assetData.supplier, assetData.oldtag, assetData.reqname, assetData.reqemail, assetData.reqcompany, userID, assetData.project, assetData.projectid, assetData.id)


    # Add asset:
    else:

      # Currently it's not allowed to add idnr manually
      if assetData.idnr != "":
        return (false, "It is not allowed to specify the IDnr. This is done automatic in the database. Row: " & $row)

      var idnrNext: string


      # WARNING
      if assetData.idnr != "" and not isDigit(assetData.idnr) and userRank == "Admin":
        return (false, "A wrong IDnr was found!! A total of " & $counter & " was added. Remove the added rows and correct the IDnr in: " & $row)

      # WARNING
      elif assetData.idnr != "" and userRank == "Admin":
        if assetCheckDuplicatesAdd(db, assetData.assettypeid, assetData.building, assetData.level, assetData.idnr):
          return (false, "An duplicate was found!! A total of " & $counter & " was added. Remove the added rows and the duplicate and try again.")

      else:
        let strictidnr = getValue(db, sql("SELECT strictidnr FROM asset_types WHERE id = ?;"), assetData.assettypeid)

        idnrNext = assetNextIdFind(db, assetData.assettypeid, assetData.building, assetData.level, strictidnr)
        if idnrNext == "":
          return (false, "Something went wrong when formatting the running number. A total of " & $counter & " was added. Remove the added rows and correct the IDnr in: " & $row)

        # Check for duplicates
        if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND building = ? AND level = ? AND idnr = ?"), assetData.assettypeid, assetData.building, assetData.level, idnrNext) != "":
          return (false, "A duplicate was found - contact the admin. A total of " & $counter & " was added. Remove the added rows and correct the IDnr in: " & $row)

      if assetData.active == "" or assetData.active notin ["Used", "Reserved", "Removed"]:
        assetData.active = "Reserved"

      assetAdd(db, assetData.active, assetData.assettypeid, assetData.typesubname, assetData.building, assetData.level, idnrNext, assetData.room, assetData.coordinates, assetData.description, assetData.supplier, assetData.oldtag, assetData.reqname, assetData.reqemail, assetData.reqcompany, userID, assetData.project, assetData.projectid)


    # Start counter
    counter += 1

  if updatedNotFound != "":
    return (true, "Success! A total of " & $counter & " was added/updated. But these asset could not be updated, due to not being found: " & updatedNotFound)

  elif updateExisting:
    return (true, "Success! A total of " & $counter & " was updated.")

  else:
    return (true, "Success! A total of " & $counter & " was added.")