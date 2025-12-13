package livekit_pkg

import (
	"context"
	"os"
)

func Init_livekit(ctx context.Context) {

	const HostURL string = "https://webrtc.otan.cc/"
	const ApiKey string = "mykey"
	const ApiSecret string = "kjskdjsdhud@djj67£@£%^&*)(DFD¬¬" + "\\" + "|??>)"

	os.Setenv("LIVEKIT_HOST", HostURL)
	os.Setenv("LIVEKIT_API_KEY", ApiKey)
	os.Setenv("LIVEKIT_API_SECRET", ApiSecret)

	// // create room service client
	// roomClient := lksdk.NewRoomServiceClient(HostURL, ApiKey, ApiSecret)

	// // use the provided ctx so higher-level cancellation works
	// res, err := roomClient.ListRooms(ctx, &livekit.ListRoomsRequest{})
	// if err != nil {
	// 	println("LiveKit ListRooms error: %v\n", err.Error())
	// 	return
	// }

	// if res == nil {
	// 	println("LiveKit ListRooms returned nil response")
	// 	return
	// }

	// // safe to access res.Rooms now
	// println("Livekit rooms: %d\n", len(res.Rooms))
}
