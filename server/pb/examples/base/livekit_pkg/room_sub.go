package livekit_pkg

// import (
// 	"encoding/json"
// 	"net/http"
// 	"net/url"
// 	"strings"

// 	livekit "github.com/livekit/protocol/livekit"
// )

// func (a *App) handleRoomSubroutes(w http.ResponseWriter, r *http.Request) {
// 	path := strings.TrimPrefix(r.URL.Path, "/rooms/")
// 	seg := strings.Split(path, "/")
// 	if len(seg) == 0 || seg[0] == "" {
// 		w.WriteHeader(http.StatusNotFound)
// 		return
// 	}
// 	roomName, _ := url.PathUnescape(seg[0])

// 	// /rooms/{room}
// 	if len(seg) == 1 {
// 		if r.Method == http.MethodDelete {
// 			c, cancel := a.ctx()
// 			defer cancel()
// 			_, err := a.RoomClient.DeleteRoom(c, &livekit.DeleteRoomRequest{Room: roomName})
// 			if err != nil {
// 				writeErr(w, http.StatusBadGateway, "delete room failed", err)
// 				return
// 			}
// 			w.WriteHeader(http.StatusNoContent)
// 			return
// 		}
// 		w.WriteHeader(http.StatusMethodNotAllowed)
// 		return
// 	}

// 	// /rooms/{room}/participants[/...]
// 	if seg[1] == "participants" {
// 		// GET /rooms/{room}/participants
// 		if len(seg) == 2 && r.Method == http.MethodGet {
// 			c, cancel := a.ctx()
// 			defer cancel()
// 			resp, err := a.RoomClient.ListParticipants(c, &livekit.ListParticipantsRequest{Room: roomName})
// 			if err != nil {
// 				writeErr(w, http.StatusBadGateway, "list participants failed", err)
// 				return
// 			}
// 			writeJSON(w, http.StatusOK, resp.Participants)
// 			return
// 		}

// 		if len(seg) >= 3 {
// 			identity, _ := url.PathUnescape(seg[2])

// 			// DELETE /rooms/{room}/participants/{identity}
// 			if len(seg) == 3 && r.Method == http.MethodDelete {
// 				c, cancel := a.ctx()
// 				defer cancel()
// 				_, err := a.RoomClient.RemoveParticipant(c, &livekit.RoomParticipantIdentity{
// 					Room:     roomName,
// 					Identity: identity,
// 				})
// 				if err != nil {
// 					writeErr(w, http.StatusBadGateway, "remove participant failed", err)
// 					return
// 				}
// 				w.WriteHeader(http.StatusNoContent)
// 				return
// 			}

// 			// POST /rooms/{room}/participants/{identity}/mute
// 			if len(seg) == 4 && seg[3] == "mute" && r.Method == http.MethodPost {
// 				var body struct {
// 					TrackSid string `json:"trackSid"`
// 					Muted    bool   `json:"muted"`
// 				}
// 				if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
// 					writeErr(w, http.StatusBadRequest, "invalid json", err)
// 					return
// 				}
// 				if body.TrackSid == "" {
// 					writeErr(w, http.StatusBadRequest, "trackSid is required", nil)
// 					return
// 				}
// 				c, cancel := a.ctx()
// 				defer cancel()
// 				_, err := a.RoomClient.MutePublishedTrack(c, &livekit.MuteRoomTrackRequest{
// 					Room:     roomName,
// 					Identity: identity,
// 					TrackSid: body.TrackSid,
// 					Muted:    body.Muted,
// 				})
// 				if err != nil {
// 					writeErr(w, http.StatusBadGateway, "mute track failed", err)
// 					return
// 				}
// 				w.WriteHeader(http.StatusNoContent)
// 				return
// 			}
// 		}
// 	}

// 	w.WriteHeader(http.StatusNotFound)
// }
