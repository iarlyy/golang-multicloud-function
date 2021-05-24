package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/iarlyy/golang-multicloud-function/function"
)

type DataPayload struct {
	Body function.MsgPayload `json:"body"`
}

type Request struct {
	Data     DataPayload `json:"req"`
	Metadata map[string]interface{}
}

type OutputsPayload struct {
	Body       function.MsgPayload `json:"body"`
	StatusCode string              `json:"statusCode"`
}

type Response struct {
	Outputs     OutputsPayload `json:"res"`
	Logs        []string
	ReturnValue interface{}
}

func handler(w http.ResponseWriter, r *http.Request) {
	var req Request
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	req_msg := function.MsgPayload{Msg: req.Data.Body.Msg}
	res_msg := req_msg.Process()
	response := Response{Outputs: OutputsPayload{Body: res_msg, StatusCode: "200"}}
	res, err := json.Marshal(response)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(res)
}

func main() {
	handlerPort, exists := os.LookupEnv("FUNCTIONS_CUSTOMHANDLER_PORT")
	if !exists {
		handlerPort = "8080"
	}
	http.HandleFunc("/api/golangmulticloud", handler)
	log.Fatal(http.ListenAndServe(":"+handlerPort, nil))
}
