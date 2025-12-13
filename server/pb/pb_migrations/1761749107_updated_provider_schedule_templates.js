/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_provider_schedule_templates")

  // remove field
  collection.fields.removeById("text_start_time")

  // remove field
  collection.fields.removeById("text_end_time")

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "date1345189255",
    "max": "",
    "min": "",
    "name": "start_time",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "date1096160257",
    "max": "",
    "min": "",
    "name": "end_time",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_provider_schedule_templates")

  // add field
  collection.fields.addAt(3, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text_start_time",
    "max": 5,
    "min": 5,
    "name": "start_time",
    "pattern": "^([0-1][0-9]|2[0-3]):[0-5][0-9]$",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text_end_time",
    "max": 5,
    "min": 5,
    "name": "end_time",
    "pattern": "^([0-1][0-9]|2[0-3]):[0-5][0-9]$",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // remove field
  collection.fields.removeById("date1345189255")

  // remove field
  collection.fields.removeById("date1096160257")

  return app.save(collection)
})
