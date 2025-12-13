package livekit_pkg

// "time"

// auth "github.com/livekit/protocol/auth"

type createRoomPayload struct {
	Name              string `json:"name"`
	EmptyTimeout      int32  `json:"emptyTimeout,omitempty"`
	DepartureTimeout  int32  `json:"departureTimeout,omitempty"`
	MaxParticipants   uint32 `json:"maxParticipants,omitempty"`
	Metadata          string `json:"metadata,omitempty"`
	MinPlayoutDelayMs uint32 `json:"minPlayoutDelay,omitempty"`
	MaxPlayoutDelayMs uint32 `json:"maxPlayoutDelay,omitempty"`
	NodeID            string `json:"nodeId,omitempty"`
}
