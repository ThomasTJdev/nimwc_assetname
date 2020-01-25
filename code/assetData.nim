# Copyright 2020 - Thomas T. Jarløv

import strutils, db_sqlite, strformat, random, logging, sequtils


proc isDigit*(str: string): bool =
  ## Reimplementation of isDigit for strings
  if str.len() == 0: return false
  for i in str:
    if not isDigit(i): return false
  return true


proc assetNextIdFind*(db: DbConn, typeid, building, level, strictidnr: string): string =
  ## Gets the next running number

  var idnrCurrent: string
  if strictidnr == "true":
    idnrCurrent = getValue(db, sql("SELECT MAX(idnr) FROM asset_data WHERE type = ?;"), typeid)

  else:
    idnrCurrent = getValue(db, sql("SELECT MAX(idnr) FROM asset_data WHERE type = ? AND building = ? AND level = ?;"), typeid, building, level)

  debug("assetNextIdFind: MAX(idnr): " & idnrCurrent)

  if idnrCurrent == "":
    return "001"

  else:
    return alignString($(parseInt(idnrCurrent) + 1), 3, align='>', fill='0')


proc assetNextIdCalc*(currentId: string): string =
  ## Gets the next running number

  if currentId == "0" or not isDigit(currentId):
    error("Plugin asset: Id to calc from is 0 (zero) or is invalid digit: " & currentId)
    return ""

  return alignString($(parseInt(currentId) + 1), 3, align='>', fill='0')


proc assetIdFormat*(idnr: string): string =
  ## Gets the next running number

  if idnr == "0" or not isDigit(idnr):
    error("Plugin asset: Id to calc from is 0 (zero) or is invalid digit: " & idnr)
    return ""

  return alignString($(parseInt(idnr)), 3, align='>', fill='0')


proc assetAdd*(db: DbConn, active, assettype, typesub, building, level, idnr, room, coordinates, description, supplier, oldtag, reqname, reqemail, reqcompany, userid, project, projectid: string) =

  exec(db, sql("INSERT INTO asset_data (active, type, typesubname, building, level, idnr, room, coordinates, description, reqName, reqEmail, reqCompany, creator, project, projectid, supplier, oldtag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"), active, assettype, typesub, building, level, idnr, room, coordinates, description, reqname, reqemail, reqcompany, userid, project, projectid, supplier, oldtag)


proc assetUpdate*(db: DbConn, active, assettype, typesub, building, level, room, coordinates, description, supplier, oldtag, reqname, reqemail, reqcompany, userid, project, projectid, id: string) =

  exec(db, sql("UPDATE asset_data SET active = ?, type = ?, typesubname = ?, building = ?, level = ?, room = ?, coordinates = ?, description = ?, reqName = ?, reqEmail = ?, reqCompany = ?, modifiedby = ?, project = ?, projectid = ?, supplier = ?, oldtag = ? WHERE id = ?;"), active, assettype, typesub, building, level, room, coordinates, description, reqname, reqemail, reqcompany, userid, project, projectid, supplier, oldtag, id)


proc assetCheckDuplicatesUpdate*(db: DbConn, assettype, building, level, idnr, id: string): bool =
  ## Check if an asset uses strict idnr

  let strictidnr = getValue(db, sql("SELECT strictidnr FROM asset_types WHERE id = ?;"), assettype)

  # Check for duplicated
  if strictidnr == "true":
    if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND idnr = ? AND id IS NOT ?;"), assettype, idnr, id) != "":
      return false

  else:
    if getValue(db, sql("SELECT id FROM asset_data WHERE building = ? AND type = ? AND level = ? AND idnr = ? AND id IS NOT ?;"), building, assettype, level, idnr, id) != "":
      return false

  return true


proc assetCheckDuplicatesAdd*(db: DbConn, assettype, building, level, idnr: string): bool =
  ## Check if an asset uses strict idnr

  let strictidnr = getValue(db, sql("SELECT strictidnr FROM asset_types WHERE id = ?;"), assettype)

  # Check for duplicated
  if strictidnr == "true":
    if getValue(db, sql("SELECT id FROM asset_data WHERE type = ? AND idnr = ?;"), assettype, idnr) != "":
      return false

  else:
    if getValue(db, sql("SELECT id FROM asset_data WHERE building = ? AND type = ? AND level = ? AND idnr = ?;"), building, assettype, level, idnr) != "":
      return false

  return true


const rlAscii  = toSeq('a'..'z')
const rhAscii  = toSeq('A'..'Z')
proc randomStringAlpha*(length: int): string =
  ## Generate random number with alpha.
  ## The length is specified as parameter.
  randomize()
  result = ""

  for i in countUp(1, length):
    var runRandom = rand(1)

    case runRandom
    of 0:
      result.add(sample(rlAscii))
    of 1:
      result.add(sample(rhAscii))
    else:
      discard

  return result