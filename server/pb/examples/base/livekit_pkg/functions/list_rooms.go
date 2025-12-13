package livekit_pkg_fn

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	livekit "github.com/livekit/protocol/livekit"
	lksdk "github.com/livekit/server-sdk-go/v2"
	"google.golang.org/protobuf/encoding/protojson"
)

func List_rooms(ctx context.Context) string {
	// get env
	HostURL := os.Getenv("LIVEKIT_HOST")
	ApiKey := os.Getenv("LIVEKIT_API_KEY")
	ApiSecret := os.Getenv("LIVEKIT_API_SECRET")

	roomClient := lksdk.NewRoomServiceClient(HostURL, ApiKey, ApiSecret)

	res, err := roomClient.ListRooms(ctx, &livekit.ListRoomsRequest{})
	if err != nil {
		fmt.Printf("LiveKit ListRooms error: %v\n", err)
		return "{}"
	}

	if res == nil {
		fmt.Println("LiveKit ListRooms returned nil response")
		return "{}"
	}

	fmt.Printf("Livekit rooms: %d\n", len(res.Rooms))

	// build a []interface{} by marshaling each proto Room to proto-json then decoding
	roomsArr := make([]interface{}, 0, len(res.Rooms))
	pjOpts := protojson.MarshalOptions{
		EmitUnpopulated: true, // include default/unset fields; set false if you don't want them
		UseProtoNames:   true, // use protobuf field names (snake_case) — see option if you prefer Go names
	}
	for _, r := range res.Rooms {
		r.EnabledCodecs = nil
		b, err := pjOpts.Marshal(r)

		if err != nil {
			fmt.Printf("failed to protojson.Marshal room: %v\n", err)
			return "{}"
		}

		// unmarshal into interface{} so we can assemble a JSON array of objects
		var v interface{}
		if err := json.Unmarshal(b, &v); err != nil {
			fmt.Printf("failed to json.Unmarshal protojson bytes: %v\n", err)
			return "{}"
		}
		roomsArr = append(roomsArr, v)
	}

	data, err := json.Marshal(roomsArr)
	if err != nil {
		fmt.Printf("failed to marshal rooms array: %v\n", err)
		return "{}"
	}

	return string(data)
}
