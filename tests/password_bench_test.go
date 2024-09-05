package tests

import (
	"github.com/jgndev/pwbot/internal/models"
	"testing"
)

func BenchmarkGeneratePassword(b *testing.B) {
	p := &models.Password{
		Uppercase: true,
		Lowercase: true,
		Numbers:   true,
		Special:   true,
		Length:    16,
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, err := p.GeneratePassword()
		if err != nil {
			b.Fatal(err)
		}
	}
}
