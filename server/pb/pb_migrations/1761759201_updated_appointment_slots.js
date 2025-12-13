/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_appointment_slots")

  // remove field
  collection.fields.removeById("text_slot_time")

  // remove field
  collection.fields.removeById("text_end_time")

  // add field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "date2981966546",
    "max": "",
    "min": "",
    "name": "slot_time",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(5, new Field({
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
  const collection = app.findCollectionByNameOrId("pbc_appointment_slots")

  // add field
  collection.fields.addAt(3, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text_slot_time",
    "max": 5,
    "min": 5,
    "name": "slot_time",
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
  collection.fields.removeById("date2981966546")

  // remove field
  collection.fields.removeById("date1096160257")

  return app.save(collection)
})
