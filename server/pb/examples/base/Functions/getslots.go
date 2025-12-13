package Functions

import (
	"encoding/json"
	"fmt"
	"log"
	"sort"

	"github.com/pocketbase/pocketbase/core"
)

func GetSlots(app core.App, providerId, date, serviceId string) string {
	// Build filter
	filter := fmt.Sprintf(
		"slot_date = '%s' && provider = '%s' && status = 'available' && available_spots > 0",
		date, providerId,
	)

	// fetch appointment slots
	appointment_slots, err := app.FindRecordsByFilter(
		"appointment_slots", // collection
		filter,              // filter
		"slot_time",         // sort by slot_time
		100,                 // limit
		0,                   // offset
	)
	if err != nil {
		log.Println("Error finding appointment_slots:", err)
		return fmt.Sprintf(`{"error": "%v"}`, err)
	}

	// NOTE: assume availability_extends are stored in a separate collection named
	// "availability_extends". If your project stores them differently, adjust the
	// collection name or filter accordingly.
	availability_extends, err := app.FindRecordsByFilter(
		"availability_extends", // collection
		filter,                 // filter
		"slot_time",            // sort by slot_time
		100,                    // limit
		0,                      // offset
	)

	if err != nil {
		log.Println("Error finding availability_extends:", err)
		// return fmt.Sprintf(`{"error": "%v"}`, err)
	}

	// Combine both record sets and convert to plain maps
	combined := make([]map[string]interface{}, 0, len(appointment_slots)+len(availability_extends))
	for _, record := range appointment_slots {
		combined = append(combined, record.PublicExport()) // exports only public fields as a JSON-safe map
	}
	for _, record := range availability_extends {
		combined = append(combined, record.PublicExport())
	}

	// Sort combined results by slot_time (string comparison). If slot_time is a
	// different format, consider parsing to time.Time here.
	sort.Slice(combined, func(i, j int) bool {
		si, _ := combined[i]["slot_time"].(string)
		sj, _ := combined[j]["slot_time"].(string)
		return si < sj
	})

	// Encode to JSON
	jsonBytes, err := json.Marshal(combined)
	if err != nil {
		log.Println("Error encoding JSON:", err)
		return fmt.Sprintf(`{"error": "%v"}`, err)
	}

	return string(jsonBytes)
}
