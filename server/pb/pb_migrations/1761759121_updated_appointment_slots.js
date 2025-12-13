/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_appointment_slots")

  // remove field
  collection.fields.removeById("text_slot_date")

  // add field
  collection.fields.addAt(10, new Field({
    "hidden": false,
    "id": "date1958190573",
    "max": "",
    "min": "",
    "name": "slot_date",
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
    "id": "text_slot_date",
    "max": 10,
    "min": 10,
    "name": "slot_date",
    "pattern": "^\\d{4}-\\d{2}-\\d{2}$",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // remove field
  collection.fields.removeById("date1958190573")

  return app.save(collection)
})
