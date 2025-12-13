package livekit_pkg_fn

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	livekit "github.com/livekit/protocol/livekit"
	lksdk "github.com/livekit/server-sdk-go/v2"
)

func Mute_participant(roomID string, participantID, track_sid string, muted bool) string {
	// get env
	host := os.Getenv("LIVEKIT_HOST")
	apiKey := os.Getenv("LIVEKIT_API_KEY")
	apiSecret := os.Getenv("LIVEKIT_API_SECRET")

	roomClient := lksdk.NewRoomServiceClient(host, apiKey, apiSecret)

	resp, err := roomClient.MutePublishedTrack(context.Background(), &livekit.MuteRoomTrackRequest{
		Room:     roomID,
		Identity: participantID,
		TrackSid: track_sid,
		Muted:    muted,
	})

	if err != nil {
		return "{\"error\": \"Failed to mute/unmute participant\"}"
	}
	data, err := json.Marshal(resp)
	if err != nil {
		fmt.Printf("failed to marshal rooms array: %v\n", err)
		return "{}"
	}

	return string(data)

}
