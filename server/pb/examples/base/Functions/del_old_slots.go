package Functions

import (
	"fmt"
	"log"
	"time"

	"github.com/pocketbase/pocketbase/core"
)

func Del_old_slots(app core.App) {
	filter := fmt.Sprintf(
		"slot_date = '%s' && status = 'available' ",
		// use AddDate to subtract one day from now and format the date
		time.Now().AddDate(0, 0, -1).Format("2006-01-02"),
	)

	appointment_slots, err := app.FindRecordsByFilter(
		"appointment_slots", // collection
		filter,              // filter
		"slot_time",         // sort by slot_time
		100,                 // limit
		0,                   // offset
	)
	if err != nil {
		log.Println("Error finding appointment_slots:", err)

	}
	for i := 0; i < len(appointment_slots); i++ {
		slot := appointment_slots[i]
		// Delete the appointment slot
		app.Delete(slot)

		// err != nil {
		// 	log.Println("Error deleting appointment_slot:", err)
		// }
	}

	//print current iso time;
	println(time.Now().Format(time.RFC3339))
}
