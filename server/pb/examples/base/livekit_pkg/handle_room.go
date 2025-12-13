package livekit_pkg

import (
	"context"

	"github.com/pocketbase/pocketbase/core"
	livekit_pkg_fn "github.com/pocketbase/pocketbase/examples/base/livekit_pkg/functions"
)

func Rtc_handler(e *core.RequestEvent, rtc_path string) error {

	switch rtc_path {
	case "list_rooms":
		{
			data := livekit_pkg_fn.List_rooms(context.Background())
			return e.JSON(200, data)
		}

	case "create_room":
		// println("Creating .. room")
		data := livekit_pkg_fn.Create_room(context.Background(), e.Auth.Id)
		return e.JSON(200, data)

	case "get_join_token":
		// println("Getting .. join_token")
		room := e.Request.URL.Query().Get("room")

		userid := e.Auth.Id
		token, err := livekit_pkg_fn.Get_join_token(room, userid, false)
		if err != nil {
			println("Error getting join token:", err.Error())
			return e.JSON(500, "{\"error\": \"Failed to get join token\"}")
		}
		return e.JSON(200, token)

	case "mute_participant":
		{
			roomid := e.Request.URL.Query().Get("roomid")
			participantid := e.Request.URL.Query().Get("participantid")
			track_sid := e.Request.URL.Query().Get("track_sid")
			muted := true
			if e.Request.URL.Query().Get("muted") == "false" {
				muted = false
			}

			resp := livekit_pkg_fn.Mute_participant(roomid, participantid, track_sid, muted)
			return e.JSON(200, resp)

		}
	case "get_participants":
		{
			roomid := e.Request.URL.Query().Get("roomid")
			resp := livekit_pkg_fn.List_participants(roomid)
			return e.JSON(200, resp)
		}

	default:
		return e.String(404, "Not found_in rtc_handler")
	}

}
