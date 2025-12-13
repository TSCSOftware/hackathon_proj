package livekit_pkg_fn

import (
	"os"
	"time"

	"github.com/livekit/protocol/auth"
)

func Get_join_token(room, identity string, isHidden bool) (string, error) {
	// get env
	apiKey := os.Getenv("LIVEKIT_API_KEY")
	apiSecret := os.Getenv("LIVEKIT_API_SECRET")

	canPublish := true
	canSubscribe := true

	at := auth.NewAccessToken(apiKey, apiSecret)

	grant := &auth.VideoGrant{
		RoomJoin:     true,
		Room:         room,
		CanPublish:   &canPublish,
		CanSubscribe: &canSubscribe,
		Hidden:       isHidden,
	}
	at.SetVideoGrant(grant).
		SetIdentity(identity).
		SetValidFor(time.Hour)

	return at.ToJWT()
}
