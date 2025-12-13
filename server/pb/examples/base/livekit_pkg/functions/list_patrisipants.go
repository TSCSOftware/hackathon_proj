package livekit_pkg_fn

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	livekit "github.com/livekit/protocol/livekit"
	lksdk "github.com/livekit/server-sdk-go/v2"
)

func List_participants(roomName string) string {

	roomClient := lksdk.NewRoomServiceClient(os.Getenv("LIVEKIT_HOST"), os.Getenv("LIVEKIT_API_KEY"), os.Getenv("LIVEKIT_API_SECRET"))

	res, _ := roomClient.ListParticipants(context.Background(), &livekit.ListParticipantsRequest{
		Room: roomName,
	})

	x := res.GetParticipants()
	data, err := json.Marshal(x)
	if err != nil {
		fmt.Printf("failed to marshal rooms array: %v\n", err)
		return "{}"
	}

	return string(data)
}
