package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "I am go_webserver and I am work!")
}

func main() {
	http.HandleFunc("/", handler)

	port := ":9090"

	fmt.Printf("Server is listening on %s...\n", port)
	err := http.ListenAndServe(port, nil)
	if err != nil {
		fmt.Println("Error:", err)
	}
}
