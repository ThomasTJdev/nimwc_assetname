# Copyright 2020 - Thomas T. Jarløv

const assetQueryData* = """
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
      ad.projectid,
      ad.supplier,
      ad.oldtag
    FROM
      asset_data AS ad
    LEFT JOIN
      asset_types AS at ON at.id = ad.type
    LEFT JOIN
      person AS pe ON pe.id = ad.creator
    LEFT JOIN
      person AS pm ON pm.id = ad.modifiedby
    $1
    GROUP BY
      ad.id
    $2;"""

const assetQueryDocumentation* = """
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
      ad.project,
      ad.projectid,
      adoc.responsecode,
      adoc.filetype,
      adoc.viewtype,
      adoc.designation,
      adoc.runningid,
      adoc.fileext,
      adoc.description
    FROM
      asset_data AS ad
    LEFT JOIN
      asset_types AS at ON at.id = ad.type
    JOIN
      asset_documentation AS adoc ON (ad."type" = adoc."type")
    $1
    ORDER
      BY ad.building, at.name, ad.level, ad.idnr;"""

const assetQueryOm* = """
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
      ad.project,
      ad.projectid,
      aom.interval,
  	  aom.description,
  	  aom.details
    FROM
      asset_data AS ad
    LEFT JOIN
      asset_types AS at ON at.id = ad.type
    JOIN
      asset_om AS aom ON (ad."type" = aom."type")
    $1
    ORDER
      BY ad.building, at.name, ad.level, ad.idnr;"""
