package Functions

import (
	// "time"

	"fmt"
	"log"
	"time"

	"github.com/pocketbase/pocketbase/core"
)

func Genarate(app core.App, providerId string, genrate_date time.Time) string {
	// get day name of next day as int
	time_now := genrate_date
	dayname := int(time_now.Weekday())

	log.Println("Next day is:", dayname)

	// Build filter
	filter := fmt.Sprintf(
		"provider = '%s' && day_of_week = '%d' ",
		providerId, dayname,
	)

	// fetch appointment slots
	templates, err := app.FindRecordsByFilter(
		"provider_schedule_templates", // collection
		filter,

		"day_of_week", // sort by slot_time
		100,           // limit
		0,             // offset
	)
	if err != nil {
		log.Println("Error finding appointment_slots:", err)

	}
	println(len(templates))
	if len(templates) == 0 {
		return ""
	}

	// {"break_times":{},"collectionId":"pbc_provider_schedule_templates","collectionName":"provider_schedule_templates","created":"2025-10-29 16:04:24.225Z","day_of_week":"1","end_time":"2022-01-01 18:00:00.123Z","id":"zpns8s23o1vekib","max_concurrent_appointments":1,"provider":"fjyzhtpog8sw9je","slot_duration_minutes":30,"start_time":"2022-01-01 09:00:00.123Z","updated":"2025-10-29 16:04:24.225Z"}

	slot_duration_minutes := templates[0].GetInt("slot_duration_minutes")
	start_time := templates[0].GetDateTime("start_time")
	end_time_pb := templates[0].GetDateTime("end_time")
	//create time slots based on start_time, end_time and slot_duration_minutes

	collection, err := app.FindCollectionByNameOrId("appointment_slots")
	if err != nil {
		log.Println("Error finding collection:", err)
	}

	// get time only form start_time withoyt date

	current_time := time.Date(
		time_now.Year(),
		time_now.Month(),
		time_now.Day(),
		start_time.Time().Hour(),
		start_time.Time().Minute(),
		0,
		0,
		time.UTC,
	)
	end_time := time.Date(
		time_now.Year(),
		time_now.Month(),
		time_now.Day(),
		end_time_pb.Time().Hour(),
		end_time_pb.Time().Minute(),
		0,
		0,
		time.UTC,
	)
	for current_time.Before(end_time) {

		// create appointment slot record
		record := core.NewRecord(collection)
		record.Set("provider", providerId)
		record.Set("service", "")
		record.Set("slot_date", current_time)
		record.Set("slot_time", current_time)
		record.Set("end_time", current_time.Add(time.Duration(slot_duration_minutes)*time.Minute))
		record.Set("status", "available")
		record.Set("booked_by", "")
		record.Set("appointment", "")
		record.Set("capacity", 1)
		record.Set("available_spots", 1)

		// save record
		err = app.Save(record)
		if err != nil {
			println("Error saving record:", err)
		}

		// increment
		current_time = current_time.Add(time.Duration(slot_duration_minutes) * time.Minute)
	}

	return ""
}

func Gen_next_slots(app core.App) {
	providers, err := app.FindRecordsByFilter(
		"providers", // collection
		"",          // filter
		"",          // sort by slot_time
		0,           // limit
		0,           // offset
	)
	if err != nil {
		log.Println("Error finding appointment_slots:", err)

	}
	println(len(providers))
	for i := range providers {
		Genarate(app, providers[i].Id, time.Now().AddDate(0, 0, 1))
	}
}
