package tests

import (
	"github.com/jgndev/pwbot/internal/models"
	"strings"
	"testing"
	"unicode"
)

func TestPassword_GeneratePassword(t *testing.T) {
	testCases := []struct {
		name      string
		password  models.Password
		wantError bool
	}{
		{
			name:      "All options enabled",
			password:  models.Password{Uppercase: true, Lowercase: true, Numbers: true, Special: true, Length: 12},
			wantError: false,
		},
		{
			name:      "Only Lowercase",
			password:  models.Password{Lowercase: true, Length: 8},
			wantError: false,
		},
		{
			name:      "Only Uppercase",
			password:  models.Password{Uppercase: true, Length: 8},
			wantError: false,
		},
		{
			name:      "Only Numbers",
			password:  models.Password{Numbers: true, Length: 8},
			wantError: false,
		},
		{
			name:      "Only Special Characters",
			password:  models.Password{Special: true, Length: 8},
			wantError: false,
		},
		{
			name:      "Uppercase and Lowercase",
			password:  models.Password{Uppercase: true, Lowercase: true, Length: 12},
			wantError: false,
		},
		{
			name:      "Uppercase and Numbers",
			password:  models.Password{Uppercase: true, Numbers: true, Length: 12},
			wantError: false,
		},
		{
			name:      "Lowercase and Numbers",
			password:  models.Password{Lowercase: true, Numbers: true, Length: 12},
			wantError: false,
		},
		{
			name:      "Uppercase and Special",
			password:  models.Password{Uppercase: true, Special: true, Length: 12},
			wantError: false,
		},
		{
			name:      "Lowercase and Special",
			password:  models.Password{Lowercase: true, Special: true, Length: 12},
			wantError: false,
		},
		{
			name:      "Uppercase, Lowercase and Special",
			password:  models.Password{Uppercase: true, Lowercase: true, Special: true, Length: 12},
			wantError: false,
		},
		{
			name:      "Uppercase, Lowercase and Numbers",
			password:  models.Password{Uppercase: true, Lowercase: true, Numbers: true, Length: 12},
			wantError: false,
		},
		{
			name:      "No options selected",
			password:  models.Password{Length: 10},
			wantError: true,
		},
		{
			name:      "Length below minimum",
			password:  models.Password{Uppercase: true, Length: 4},
			wantError: false,
		},
		{
			name:      "Length above maximum",
			password:  models.Password{Uppercase: true, Length: 70},
			wantError: false,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			got, err := tc.password.GeneratePassword()

			if (err != nil) != tc.wantError {
				t.Errorf("GeneratePassword() error = %v, wantError %v", err, tc.wantError)
				return
			}

			if !tc.wantError {
				if len(got) != tc.password.Length {
					t.Errorf("GeneratePassword() length = %v, want %v", len(got), tc.password.Length)
				}

				validatePassword(t, got, tc.password)
			}
		})
	}
}

func validatePassword(t *testing.T, password string, opts models.Password) {
	var hasUpper, hasLower, hasNumber, hasSpecial bool

	for _, char := range password {
		switch {
		case unicode.IsUpper(char):
			hasUpper = true
		case unicode.IsLower(char):
			hasLower = true
		case unicode.IsDigit(char):
			hasNumber = true
		case strings.ContainsRune(models.Special, char):
			hasSpecial = true
		}
	}

	if opts.Uppercase && !hasUpper {
		t.Errorf("Password does not contain uppercase letters")
	}
	if opts.Lowercase && !hasLower {
		t.Errorf("Password does not contain lowercase letters")
	}
	if opts.Numbers && !hasNumber {
		t.Errorf("Password does not contain numbers")
	}
	if opts.Special && !hasSpecial {
		t.Errorf("Password does not contain special characters")
	}
}

func TestPassword_ClampLength(t *testing.T) {
	tests := []struct {
		name     string
		password models.Password
		want     int
	}{
		{"Below minimum", models.Password{Length: 3}, models.MinLength},
		{"Above maximum", models.Password{Length: 100}, models.MaxLength},
		{"Within range", models.Password{Length: 20}, 20},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tt.password.ClampLength()
			if tt.password.Length != tt.want {
				t.Errorf("clampLength() = %v, want %v", tt.password.Length, tt.want)
			}
		})
	}
}
