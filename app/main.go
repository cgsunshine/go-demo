package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	version := os.Getenv("APP_VERSION")
	if version == "" {
		version = "unknown"
	}
	env := os.Getenv("APP_ENV")
	if env == "" {
		env = "local"
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "hello from go ci/cd, env=%s, version=%s\n", env, version)
	})
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "ok")
	})
	fmt.Println("listening on :8080 env=", env, "version=", version)
	http.ListenAndServe(":8080", nil)
}