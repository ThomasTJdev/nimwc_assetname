# Copyright 2020 - Thomas T. Jarløv

import nimlibxlsxwriter/xlsxwriter


import datetime2human, strutils, db_sqlite, re, times, os

import
  random,
  sequtils

from math import ceil

import assetQueries, assetData


proc assetXlsx*(db: DbConn, queryWhere, storagePath, exportType: string): tuple[b: bool, path, filename: string] =
  ## Export assets to XLSX

  let
    queryString = assetQueryData.format(queryWhere, " ORDER BY ad.building, at.name, ad.level, ad.idnr")
    assets = getAllRows(db, sql(queryString))
    assetsDocumentation = getAllRows(db, sql(assetQueryDocumentation.format(queryWhere))) #, "")))
    assetsOm = getAllRows(db, sql(assetQueryOm.format(queryWhere))) #, "")))

  # Get date in readable format
  let date = epochDate($toInt(epochTime()), "YYYY-MM-DD")
  let path = storagePath
  var filename = date & " - " & exportType & "_assets.xlsx"
  if fileExists(path / filename):
    filename = date & " - " & exportType & "_assets" & "_" & randomStringAlpha(6) & ".xlsx"

  var workbook: ptr lxw_workbook = workbook_new(path / filename)

  # Add a worksheet with a user defined sheet name.
  var worksheet1: ptr lxw_worksheet = workbook_add_worksheet(workbook, "Assets")
  var worksheet2: ptr lxw_worksheet = workbook_add_worksheet(workbook, "Dokumentation")
  var worksheet3: ptr lxw_worksheet = workbook_add_worksheet(workbook, "D&V")

  # Set the header
  discard worksheet_set_header(worksheet1, "&LCx Manager&R" & date)

  # Define the printing layout
  worksheet_set_landscape(worksheet1)
  worksheet_fit_to_pages(worksheet1, 1, 0)
  worksheet_set_margins(worksheet1, 0.3, 0.3, 0.5, 0.5)
  worksheet_set_paper(worksheet1, 8) # A3 paper size

  # Cell formats
  var formatOverall: ptr lxw_format = workbook_add_format(workbook)
  var formatHeading: ptr lxw_format = workbook_add_format(workbook)
  var formatText: ptr lxw_format = workbook_add_format(workbook)
  var formatTextCenter: ptr lxw_format = workbook_add_format(workbook)
  var formatTextYellow: ptr lxw_format = workbook_add_format(workbook)
  var formatTextYellowCenter: ptr lxw_format = workbook_add_format(workbook)
  var formatTextRed: ptr lxw_format = workbook_add_format(workbook)
  var formatTextRedCenter: ptr lxw_format = workbook_add_format(workbook)
  var formatGrey: ptr lxw_format = workbook_add_format(workbook)

  # Set formatOverall
  format_set_bold(formatOverall)
  format_set_font_name(formatOverall, "Arial")
  format_set_font_size(formatOverall, 16)
  format_set_border(formatOverall, 1)
  format_set_border_color(formatOverall, 0x1000000)
  format_set_align(formatOverall, 10)

  # Set formatGrey
  format_set_bg_color(formatGrey, 0xCCCCCC)
  format_set_border(formatGrey, 1)
  format_set_border_color(formatGrey, 0x1000000)

  # Set formatHeading
  format_set_bold(formatHeading)
  format_set_bg_color(formatHeading, 0x171921)
  format_set_font_name(formatHeading, "Arial")
  format_set_font_size(formatHeading, 12)
  format_set_font_color(formatHeading, 0xFFFFFF)
  format_set_border(formatHeading, 1)
  format_set_border_color(formatHeading, 0x1000000)
  format_set_align(formatHeading, 10)
  format_set_align(formatHeading, 2)
  format_set_text_wrap(formatHeading)

  # Set formatText
  format_set_bg_color(formatText, 0xFFFFFF)
  format_set_font_name(formatText, "Arial")
  format_set_font_size(formatText, 10)
  format_set_font_color(formatText, 0x1000000)
  format_set_border(formatText, 1)
  format_set_border_color(formatText, 0x1000000)
  format_set_align(formatText, 10)
  format_set_text_wrap(formatText)

  # Set formatTextCenter
  format_set_bg_color(formatTextCenter, 0xFFFFFF)
  format_set_font_name(formatTextCenter, "Arial")
  format_set_font_size(formatTextCenter, 10)
  format_set_font_color(formatTextCenter, 0x1000000)
  format_set_border(formatTextCenter, 1)
  format_set_border_color(formatTextCenter, 0x1000000)
  format_set_align(formatTextCenter, 10)
  format_set_text_wrap(formatTextCenter)
  format_set_align(formatTextCenter, 10)
  format_set_align(formatTextCenter, 2)

  # Set formatTextYellow
  format_set_bg_color(formatTextYellow, 0xFDD253)
  format_set_font_name(formatTextYellow, "Arial")
  format_set_font_size(formatTextYellow, 10)
  format_set_font_color(formatTextYellow, 0x1000000)
  format_set_border(formatTextYellow, 1)
  format_set_border_color(formatTextYellow, 0x1000000)
  format_set_align(formatTextYellow, 10)
  format_set_text_wrap(formatTextYellow)

  # Set formatTextYellowCenterCenter
  format_set_bg_color(formatTextYellowCenter, 0xFDD253)
  format_set_font_name(formatTextYellowCenter, "Arial")
  format_set_font_size(formatTextYellowCenter, 10)
  format_set_font_color(formatTextYellowCenter, 0x1000000)
  format_set_border(formatTextYellowCenter, 1)
  format_set_border_color(formatTextYellowCenter, 0x1000000)
  format_set_align(formatTextYellowCenter, 10)
  format_set_text_wrap(formatTextYellowCenter)
  format_set_align(formatTextYellowCenter, 10)
  format_set_align(formatTextYellowCenter, 2)

  # Set formatTextRed
  format_set_bg_color(formatTextRed, 0xFD7553)
  format_set_font_name(formatTextRed, "Arial")
  format_set_font_size(formatTextRed, 10)
  format_set_font_color(formatTextRed, 0x1000000)
  format_set_border(formatTextRed, 1)
  format_set_border_color(formatTextRed, 0x1000000)
  format_set_align(formatTextRed, 10)
  format_set_text_wrap(formatTextRed)

  # Set formatTextRedCenterCenter
  format_set_bg_color(formatTextRedCenter, 0xFD7553)
  format_set_font_name(formatTextRedCenter, "Arial")
  format_set_font_size(formatTextRedCenter, 10)
  format_set_font_color(formatTextRedCenter, 0x1000000)
  format_set_border(formatTextRedCenter, 1)
  format_set_border_color(formatTextRedCenter, 0x1000000)
  format_set_align(formatTextRedCenter, 10)
  format_set_text_wrap(formatTextRedCenter)
  format_set_align(formatTextRedCenter, 10)
  format_set_align(formatTextRedCenter, 2)


  discard worksheet_write_string(worksheet1, 0, 0, "Assets", formatOverall)

  var col = 0'u16
  discard worksheet_set_column(worksheet1, col, col, 5, nil)
  discard worksheet_write_string(worksheet1, 2, col, "ID", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 20, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Tag nr.", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Active", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Type", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Type sub", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 5, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Building", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 5, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Level", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 5, nil)
  discard worksheet_write_string(worksheet1, 2, col, "IDnr", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Room", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 15, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Coordinates", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 30, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Description", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Supplier", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Old tag", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 15, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Reg. name", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 20, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Reg. email", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 15, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Req. company", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 15, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Project", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Project ID", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Created by", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Modified by", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet1, col, col, 10, nil)
  discard worksheet_write_string(worksheet1, 2, col, "Last edited", formatHeading)

  # Set row height
  discard worksheet_set_row(worksheet1, 2, 30, nil)

  var rowNr = 2'u32
  var colNr = 0'u16
  for a in assets:
    let
      id = a[0]
      typeName = a[1]
      active = a[2]
      typeId = a[3]
      typeSub = a[4]
      building = a[5]
      level = a[6]
      idnr = a[7]
      item1 = a[8]
      room = a[9]
      coordinates = a[10]
      description = a[11]
      modified = a[12]
      reqName = a[13]
      reqEmail = a[14]
      reqCompany = a[15]
      creatorName = a[16]
      modifiedName = a[17]
      project = a[18]
      projectid = a[19]
      supplier = a[20]
      oldtag = a[21]

    # Set test options
    let formatChoice = if active == "Reserved": formatTextYellow elif active == "Removed": formatTextRed else: formatText
    let formatChoiceCenter = if active == "Reserved": formatTextYellowCenter elif active == "Removed": formatTextRedCenter else: formatTextCenter

    # Set row number
    rowNr += 1'u32

    colNr = 0'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, id, formatChoiceCenter)

    var tagname = typeName & "-" & building & "-" & level & "-" & idnr
    if typeSub != "":
      tagname = typeName & "-" & building & "-" & level & "-" & idnr & "-" & typeSub

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, tagname, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, active, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, typeName, formatChoiceCenter)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, typeSub, formatChoiceCenter)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, building, formatChoiceCenter)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, level, formatChoiceCenter)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, idnr, formatChoiceCenter)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, room, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, coordinates, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, description, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, supplier, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, oldtag, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, reqName, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, reqEmail, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, reqCompany, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, project, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, projectid, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, creatorName, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, modifiedName, formatChoice)

    colNr += 1'u16
    discard worksheet_write_string(worksheet1, rowNr, colNr, epochDate(modified, "YYYY-MM-HH HH:mm"), formatChoiceCenter)




  # NEXT WORKSHEET

  discard worksheet_write_string(worksheet2, 0, 0, "Dokumentation", formatOverall)

  col = 0'u16
  discard worksheet_set_column(worksheet2, col, col, 10, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Bygning", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 8, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Ansvar", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 8, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Filtype", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 8, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Niveau", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 15, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Anlæg", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 10, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Komponent", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 10, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Betegnelse", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 10, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Betegnelse", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 10, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Løbenr", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 40, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Tegningsnummer", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 10, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Rum", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 15, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Projektnavn", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 5, nil)
  discard worksheet_write_string(worksheet2, 2, col, "TOM", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 20, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Beskrivelse", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 10, nil)
  discard worksheet_write_string(worksheet2, 2, col, "Filformat", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 5, nil)
  discard worksheet_write_string(worksheet2, 2, col, "TOM", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet2, col, col, 30, nil)
  discard worksheet_write_string(worksheet2, 2, col, "SAP", formatHeading)

  # Set row height
  discard worksheet_set_row(worksheet2, 2, 30, nil)

  rowNr = 2'u32
  for a in assetsDocumentation:
    let
      id = a[0]
      typeName = a[1]
      active = a[2]
      typeId = a[3]
      typeSub = a[4]
      building = a[5]
      level = a[6]
      idnr = a[7]
      item1 = a[8]
      room = a[9]
      coordinates = a[10]
      description = a[11]
      modified = a[12]
      reqName = a[13]
      reqEmail = a[14]
      reqCompany = a[15]
      project = a[16]
      projectid = a[17]
      responsecode = a[18]
      filetype = a[19]
      viewtype = a[20]
      designation = a[21]
      runningid = a[22]
      fileext = a[23]
      filedescription = a[24]

      tagnrShort = typeName & "_" & building & "_" & level & "_" & idnr
      tagnrSAP = typeName & "-" & building & "-" & level & "-" & idnr

      typeshortCheck = if typeSub == "": "XX" else: typeSub

      filename = building & "-" & responsecode & "-" & filetype & "-" & level  & "-" & viewtype & "-" & typeName & "_" & idnr & "-" & typeshortCheck & "-" & designation  & runningid & "-" & fileext

    # Set row number
    rowNr += 1'u32
    colNr = 0'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, building, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, responsecode, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, filetype, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, level, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, typeName & "_" & idnr, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, typeshortCheck, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, designation, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, designation, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, runningid, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, filename, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, room, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, project, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, " ", formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, filedescription, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, fileext, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, " ", formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet2, rowNr, colNr, tagnrSAP, formatText)



  # NEXT WORKSHEET

  discard worksheet_write_string(worksheet3, 0, 0, "D&V", formatOverall)

  col = 0'u16
  discard worksheet_set_column(worksheet3, col, col, 20, nil)
  discard worksheet_write_string(worksheet3, 2, col, "Anlægsnavn", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet3, col, col, 20, nil)
  discard worksheet_write_string(worksheet3, 2, col, "Anlægsbeskrivelse", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet3, col, col, 10, nil)
  discard worksheet_write_string(worksheet3, 2, col, "Interval", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet3, col, col, 10, nil)
  discard worksheet_write_string(worksheet3, 2, col, "Enhed", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet3, col, col, 35, nil)
  discard worksheet_write_string(worksheet3, 2, col, "Beskrivelse", formatHeading)

  col += 1'u16
  discard worksheet_set_column(worksheet3, col, col, 35, nil)
  discard worksheet_write_string(worksheet3, 2, col, "Detaljer", formatHeading)

  # Set row height
  discard worksheet_set_row(worksheet3, 2, 30, nil)

  var asset: string
  rowNr = 2'u32
  for a in assetsOm:
    let
      id = a[0]
      typeName = a[1]
      active = a[2]
      typeId = a[3]
      typeSub = a[4]
      building = a[5]
      level = a[6]
      idnr = a[7]
      item1 = a[8]
      room = a[9]
      coordinates = a[10]
      description = a[11]
      modified = a[12]
      reqName = a[13]
      reqEmail = a[14]
      reqCompany = a[15]
      project = a[16]
      projectid = a[17]
      interval = a[18]
      omdescription = a[19]
      details = a[20]

      tagnrSAP = typeName & "-" & building & "-" & level & "-" & idnr

    # Set row number
    rowNr += 1'u32

    if asset != "" and asset != tagnrSAP:
      colNr = 0'u16
      for i in countup(0, 5):
        discard worksheet_write_string(worksheet3, rowNr, colNr, " ", formatGrey)
        colNr += 1'u16
      asset = tagnrSAP
      rowNr += 1'u32

    asset = tagnrSAP

    colNr = 0'u16
    discard worksheet_write_string(worksheet3, rowNr, colNr, tagnrSAP, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet3, rowNr, colNr, description, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet3, rowNr, colNr, interval, formatTextCenter)

    colNr += 1'u16
    discard worksheet_write_string(worksheet3, rowNr, colNr, "måned", formatTextCenter)

    colNr += 1'u16
    discard worksheet_write_string(worksheet3, rowNr, colNr, omdescription, formatText)

    colNr += 1'u16
    discard worksheet_write_string(worksheet3, rowNr, colNr, details.replace("\r", ""), formatText)

    var linesDescr: float
    # First check for new lines and them. +1 is needed
    # if there's no new lines - we always need 1 line
    if omdescription.contains("\n"):
      linesDescr = toFloat(count(omdescription, "\n") + 1)
      for line in split(omdescription, "\n"):
        if line.len() > 70:
          linesDescr += ceil(line.len() / 70) - 1.0
    # If there's no new lines, do basic calculation to
    # define new lines based on line length
    else:
      linesDescr += ceil(omdescription.len() / 70)


    var linesDetails: float
    # First check for new lines and them. +1 is needed
    # if there's no new lines - we always need 1 line
    if details.contains("\n"):
      linesDetails = toFloat(count(details, "\n") + 1)
      for line in split(details, "\n"):
        if line.len() > 70:
          linesDetails += ceil(line.len() / 70) - 1.0
    # If there's no new lines, do basic calculation to
    # define new lines based on line length
    else:
      linesDetails += ceil(details.len() / 70)

    if linesDescr > linesDetails:
       discard worksheet_set_row(worksheet3, rowNr, linesDescr * 15, nil)
    elif linesDetails > linesDescr:
      discard worksheet_set_row(worksheet3, rowNr, linesDetails * 15, nil)


  # Close the workbook, save the file and free any memory.
  var error = workbook_close(workbook)

  # Check if there was any error creating the xlsx file.
  if error.int != 0:
    echo "Error in workbook_close()\n"
    return (false, "Error $1 = $2" % [$error, $lxw_strerror(error)], "")


  return (true, path / filename, filename)