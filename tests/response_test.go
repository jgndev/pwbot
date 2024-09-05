package tests

import (
	"encoding/json"
	"github.com/jgndev/pwbot/internal/models"
	"testing"
)

func TestResponse(t *testing.T) {
	t.Run("Create Response", func(t *testing.T) {
		password := "testPassword123!"
		response := models.Response{Password: password}

		if response.Password != password {
			t.Errorf("Expected password to be %s, got %s", password, response.Password)
		}
	})

	t.Run("JSON Marshalling", func(t *testing.T) {
		response := models.Response{Password: "testPassword123!"}
		jsonData, err := json.Marshal(response)

		if err != nil {
			t.Fatalf("Failed to marshal Response to JSON: %v", err)
		}

		expectedJSON := `{"Password":"testPassword123!"}`
		if string(jsonData) != expectedJSON {
			t.Errorf("Expected JSON %s, got %s", expectedJSON, string(jsonData))
		}
	})

	t.Run("JSON Unmarshalling", func(t *testing.T) {
		jsonData := []byte(`{"Password":"testPassword123!"}`)
		var response models.Response

		err := json.Unmarshal(jsonData, &response)
		if err != nil {
			t.Fatalf("Failed to unmarshal JSON to Response: %v", err)
		}

		expectedPassword := "testPassword123!"
		if response.Password != expectedPassword {
			t.Errorf("Expected password to be %s, got %s", expectedPassword, response.Password)
		}
	})
}
