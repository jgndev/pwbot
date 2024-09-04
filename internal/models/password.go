package models

import (
	"errors"
	"math/rand"
	"strings"
)

const (
	uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	lowercase = "abcdefghijklmnopqrstuvwxyz"
	numbers   = "0123456789"
	special   = "!@#$%^&*-_=+<>?;:[]{}(),./|"
	minLength = 6
	maxLength = 64
)

type Password struct {
	Uppercase bool
	Lowercase bool
	Numbers   bool
	Special   bool
	Length    int
}

func (p *Password) GeneratePassword() (string, error) {
	// clamp the length to a minimum of 6 and maximum of 64 characters
	p.clampLength()

	// create the string of possible characters based on options
	var possible strings.Builder
	possible.Grow(len(uppercase) + len(lowercase) + len(numbers) + len(special))
	if p.Uppercase {
		possible.WriteString(uppercase)
	}

	if p.Lowercase {
		possible.WriteString(lowercase)
	}

	if p.Numbers {
		possible.WriteString(numbers)
	}

	if p.Special {
		possible.WriteString(special)
	}

	if possible.Len() == 0 {
		return "", errors.New("no character set selected")
	}

	// create a new string to hold the password
	var pw strings.Builder
	// allocate enough memory for the entire password string
	pw.Grow(p.Length)

	// seed the random number generator
	chars := possible.String()

	for i := 0; i < p.Length; i++ {
		// create a random index
		rdx := rand.Intn(len(chars))
		// get the character at the random index of the possible string
		// and write it to the pw string.
		pw.WriteByte(chars[rdx])
	}

	return pw.String(), nil
}

func (p *Password) clampLength() {
	// clamp the min length to minLength
	if p.Length < minLength {
		p.Length = minLength
	}

	// clamp the max length to maxLength
	if p.Length > maxLength {
		p.Length = maxLength
	}
}
