#
#
#        TTJ
#        (c) Copyright 2020 Thomas Toftgaard Jarløv
#        Plugin for Nim Website Creator: Assetname
#        License: MIT
#
#

import
  asyncdispatch,
  datetime2human,
  logging,
  os,
  parsecfg,
  re,
  smtp,
  strformat,
  strutils

from times import epochTime

import ../../nimwcpkg/constants/constants
import ../../nimwcpkg/emails/emails
import ../../nimwcpkg/files/files
import ../../nimwcpkg/plugins/plugins

when defined(postgres): import db_postgres
else:                   import db_sqlite

import code/assetQueries
export assetQueryData
import code/exportAssets
export assetXlsx

let (assetN, assetV*, assetD, assetU) = pluginGetDetails("assetname")
proc pluginInfo() =
  echo " "
  echo "--------------------------------------------"
  echo "  Package:      " & assetN
  echo "  Version:      " & assetV
  echo "  Description:  " & assetD
  echo "  URL:          " & assetU
  echo "--------------------------------------------"
  echo " "
pluginInfo()


let
  appDir = getAppDir().replace("nimwcpkg", "")
  dict = loadConfig(appDir / "config/config.cfg")
  supportEmail = dict.getSectionValue("SMTP", "SMTPEmailSupport")
  smtpAddress = dict.getSectionValue("SMTP", "SMTPAddress")
  smtpPort = dict.getSectionValue("SMTP", "SMTPPort")
  smtpFrom = dict.getSectionValue("SMTP", "SMTPFrom")
  smtpUser = dict.getSectionValue("SMTP", "SMTPUser")
  smtpPassword = dict.getSectionValue("SMTP", "SMTPPassword")


#[#ad.type = ? AND ad.building = ?
  var where: string
  if typeid:
    where.add(" ad.type = ? ")
  if building:
    if where != "": where.add(" AND ")
    where.add(" ad.building = ? ")
  if level:
    if where != "": where.add(" AND ")
    where.add(" ad.level = ? ")
  if activeUsed:
    if where != "": where.add(" AND ")
    where.add(" ad.active = 'Used' ")
  if activeReserved:
    if where != "": where.add(" AND ")
    where.add(" ad.active = 'Reserved' ")
  if room:
    if where != "": where.add(" AND ")
    where.add(" ad.room = ? ")
  if reqName:
    if where != "": where.add(" AND ")
    where.add(" ad.reqName = ? ")
  if reqEmail:
    if where != "": where.add(" AND ")
    where.add(" ad.reqEmail = ? ")
  if reqCompany:
    if where != "": where.add(" AND ")
    where.add(" ad.reqCompany = ? ")
  if creator:
    if where != "": where.add(" AND ")
    where.add(" ad.creator = ? ")]#


proc assetQuery*(typeid = false, building = false, level = false, activeUsed = false, activeReserved = false, room = false, reqName = false, reqEmail = false, reqCompany = false, creator = false, sasset, sbuilding, slevel, sroom, sreqname, sreqemail, sreqcompany, screator: string): string =
  ## Generate the select query for assets. Specify the where clause.

  #ad.type = ? AND ad.building = ?
  var where: string
  if typeid:
    where.add(" ad.type = " & dbQuote(sasset))
  if building:
    if where != "": where.add(" AND ")
    where.add(" ad.building = " & dbQuote(sbuilding))
  if level:
    if where != "": where.add(" AND ")
    where.add(" ad.level = " & dbQuote(slevel))
  if activeUsed:
    if where != "": where.add(" AND ")
    where.add(" ad.active = 'Used' ")
  elif activeReserved:
    if where != "": where.add(" AND ")
    where.add(" ad.active = 'Reserved' ")
  if room:
    if where != "": where.add(" AND ")
    where.add(" ad.room = " & dbQuote(sroom))
  if reqName:
    if where != "": where.add(" AND ")
    where.add(" ad.reqName = " & dbQuote(sreqname))
  if reqEmail:
    if where != "": where.add(" AND ")
    where.add(" ad.reqEmail = " & dbQuote(sreqemail))
  if reqCompany:
    if where != "": where.add(" AND ")
    where.add(" ad.reqCompany = " & dbQuote(sreqcompany))
  if creator:
    if where != "": where.add(" AND ")
    where.add(" ad.creator = " & dbQuote(screator))

  if where != "":
    where = "WHERE " & where

  #[
  let query = """
    SELECT
      ad.id,
      at.name,
      ad.active,
      ad.type,
      ad.typesubname,
      ad.building,
      ad.level,
      ad.idnr,
      ad.item1,
      ad.room,
      ad.coordinates,
      ad.description,
      ad.modified,
      ad.reqName,
      ad.reqEmail,
      ad.reqCompany,
      pe.name,
      pm.name,
      ad.project,
      ad.projectid
    FROM
      asset_data AS ad
    LEFT JOIN
      asset_types AS at ON at.id = ad.type
    LEFT JOIN
      person AS pe ON pe.id = ad.creator
    LEFT JOIN
      person AS pm ON pe.id = ad.modifiedby
    $1
    GROUP BY
      ad.id
    ORDER
      BY ad.building, at.name, ad.level, ad.idnr;""" % [where]]#

  return where



include "nimfs/settings.nimf"
include "nimfs/assets.nimf"
include "nimfs/requests.nimf"


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

#[
proc sendassetReceipt*(mailTo, subject, msg, filepath, receiptNr: string) {.async.} =
  ## Send email with the receipt as an attachment
  var multi = newMimeMessage()

  # Main data
  multi.body = msg
  multi.header["to"] = @[mailTo].mimeList
  multi.header["subject"] = subject

  # Add test to email body
  var first = newMimeMessage()
  first.header["Content-Type"] = "text/html"
  first.body = msg
  # Check if encoding is needed
  first.encodeQuotedPrintables()
  multi.parts.add first

  # Add attachement
  var image = newAttachment(readFile(filepath), filename = assetLang("receipt") & "_" & receiptNr & ".pdf")
  image.encodeQuotedPrintables()
  multi.parts.add image

  ## Send it using smtp
  var smtpConn = newAsyncSmtp(useSsl = true, debug = false)

  try:
    await smtpConn.connect(smtpAddress, Port(parseInt(smtpPort)))
    await smtpConn.auth(smtpUser, smtpPassword)
    await smtpConn.sendMail(smtpFrom,  @[mailTo], $multi.finalize())
    await smtpConn.close()
  except:
    error("Plugin asset: Error in sending receipt")
]#

proc deleteFileAsync*(path: string, beforeDelete: int) {.async.} =
  ## Deletes a file after a given amount of time
  ## beforeDelete => When to delete in seconds from now

  if path == "":
    return

  # Check if file exists
  if not existsFile(path):
    return

  # Sleep before delete
  await sleepAsync(1000 * beforeDelete)

  # Remove the file
  discard tryRemoveFile(path)
  return


proc assetnameStart*(db: DbConn) =
  ## Required proc. Will run on each program start
  ##
  ## If there's no need for this proc, just
  ## discard it. The proc may not be removed.

  info("Assetname plugin: Updating database with Assetname table if not exists")

  if not db.tryExec(sql"""
  create table if not exists asset_settings (
    id INTEGER primary key,
    modified timestamp not null default (STRFTIME('%s', 'now')),
    creation timestamp not null default (STRFTIME('%s', 'now'))
  );""", []):
    error("asset plugin: Could not create table")


  if not db.tryExec(sql"""
  create table if not exists asset_types (
    id INTEGER          primary key,
    name                VARCHAR(100),
    subname             VARCHAR(100),
    strictidnr          VARCHAR(10),
    description         TEXT,
    modified timestamp not null default (STRFTIME('%s', 'now')),
    creation timestamp not null default (STRFTIME('%s', 'now'))
  );""", []):
    error("asset plugin: Could not create table")


  if not db.tryExec(sql"""
  create table if not exists asset_data (
    id INTEGER   primary key,
    active       VARCHAR(20),
    type         INTEGER,
    typesubname  VARCHAR(100),
    building     VARCHAR(100) NOT NULL,
    level        VARCHAR(100) NOT NULL,
    idnr         VARCHAR(100) NOT NULL,
    item1        VARCHAR(100),
    room         VARCHAR(100),
    coordinates  VARCHAR(1000),
    description  VARCHAR(1000),

    creator      INTEGER,
    modifiedby   INTEGER,

    reqName      VARCHAR(256),
    reqEmail     VARCHAR(256),
    reqCompany   VARCHAR(256),

    project      VARCHAR(200),
    projectid    VARCHAR(200),

    modified timestamp not null default (STRFTIME('%s', 'now')),
    creation timestamp not null default (STRFTIME('%s', 'now')),

    foreign key (type) references asset_types(id),
    foreign key (creator) references person(id),
    foreign key (modifiedby) references person(id)
  );""", []):
    error("asset plugin: Could not create table")


  if not db.tryExec(sql"""
  create table if not exists asset_om (
    id INTEGER   primary key,
    type         INTEGER,
    interval     INTEGER,
    description  TEXT NOT NULL,
    details      TEXT NOT NULL,
    modified timestamp not null default (STRFTIME('%s', 'now')),
    creation timestamp not null default (STRFTIME('%s', 'now')),

    foreign key (type) references asset_types(id)
  );""", []):
    error("asset plugin: Could not create table")


  # [_FINE_]-[RESPONSECODE]-[FILETYPE]-[_FLOOR_]-[VIEWTYPE]-[_ASSET_]-[_SUBTYPE_].[EXT]
  if not db.tryExec(sql"""
  create table if not exists asset_documentation (
    id INTEGER   primary key,
    type         INTEGER,
    responsecode VARCHAR(100),
    filetype     VARCHAR(100),
    viewtype     VARCHAR(100),
    designation  VARCHAR(100),
    runningid    VARCHAR(100),
    fileext      VARCHAR(100),
    description  TEXT,
    modified timestamp not null default (STRFTIME('%s', 'now')),
    creation timestamp not null default (STRFTIME('%s', 'now')),

    foreign key (type) references asset_types(id)
  );""", []):
    error("asset plugin: Could not create table")


  info("asset plugin: Creating folder for files")
  discard existsOrCreateDir(storageEFS / "assetname")
