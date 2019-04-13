package main

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)


func TestHandler(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rec := httptest.NewRecorder()

	Handler(rec, req)

	if got, want := rec.Code, http.StatusOK; got != want {
		t.Fatalf("wrong http status: got: %d, want: %d", got, want)
	}

	b, err := ioutil.ReadAll(rec.Body)
	if err != nil {
		t.Fatalf("failed to load JSON message: %s", err)
	}

	var body map[string]string
	if e := json.Unmarshal(b, &body); e != nil {
		t.Fatalf("failed to unmarshal response: %s", err)
	}

	if m := body["message"]; !strings.HasPrefix(m, "Hello Spinnaker") {
		t.Fatalf("wrong JSON message: %s", m)
	}
}
