package golangmulticloudfunction

import (
	"encoding/json"
	"net/http"

	"github.com/iarlyy/golang-multicloud-function/function"
)

func Handler(w http.ResponseWriter, r *http.Request) {
	var req function.MsgPayload
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	req_msg := function.MsgPayload{Msg: req.Msg}
	res_msg := req_msg.Process()
	res, err := json.Marshal(res_msg)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(res)
}
