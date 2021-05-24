package function

import "time"

type MsgPayload struct {
	Msg string `json:"msg"`
	Now string `json:"now,omitempty"`
}

func (m *MsgPayload) Process() MsgPayload {
	now := time.Now().Format(time.RFC3339)
	return MsgPayload{Msg: m.Msg, Now: now}
}
