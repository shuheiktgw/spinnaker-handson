package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", Handler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func Handler(w http.ResponseWriter, _ *http.Request) {
	err := json.NewEncoder(w).Encode(map[string]string{"message": fmt.Sprintf("Hello Spinnaker v1.0.0!")})

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
	} else {
		w.WriteHeader(http.StatusOK)
	}
}
