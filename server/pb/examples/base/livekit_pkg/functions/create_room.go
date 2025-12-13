package livekit_pkg_fn

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"os"

	livekit "github.com/livekit/protocol/livekit"
	lksdk "github.com/livekit/server-sdk-go/v2"
)

func Create_room(ctx context.Context, ownerid string) string {

	host := os.Getenv("LIVEKIT_HOST")
	apiKey := os.Getenv("LIVEKIT_API_KEY")
	apiSecret := os.Getenv("LIVEKIT_API_SECRET")

	roomClient := lksdk.NewRoomServiceClient(host, apiKey, apiSecret)
	metadata_map := map[string]any{
		"created_by": ownerid,
	}
	metadata, _ := json.Marshal(metadata_map)

	room, err := roomClient.CreateRoom(ctx, &livekit.CreateRoomRequest{
		Name:             "room-" + randHex(10),
		EmptyTimeout:     60 * 20,
		DepartureTimeout: 60 * 10,
		Metadata:         string(metadata),
	})
	if err != nil {
		println("Error creating room:", err.Error())
		return "{\"error\": \"Failed to create room\"}"
	}

	data, err := json.Marshal(room)
	if err != nil {
		println("Error marshalling room:", err.Error())
		return "{\"error\": \"Failed to create room\"}"
	}

	println("Created room:", string(data))
	return string(data)
}

func randHex(n int) string {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		return "room"
	}
	return hex.EncodeToString(b)
}
