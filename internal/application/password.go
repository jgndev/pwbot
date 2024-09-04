package application

import (
	"github.com/jgndev/pwbot/internal/models"
	"github.com/labstack/echo/v4"
	"html/template"
	"strconv"
)

func NewPassword(c echo.Context) error {
	err := c.Request().ParseForm()
	if err != nil {
		return err
	}

	// parse form values
	uppercase := c.FormValue("uppercae") == "on"
	lowercase := c.FormValue("lowercase") == "on"
	numbers := c.FormValue("numbers") == "on"
	special := c.FormValue("special") == "on"
	length, _ := strconv.Atoi(c.FormValue("length"))

	pwo := models.Password{
		Uppercase: uppercase,
		Lowercase: lowercase,
		Numbers:   numbers,
		Special:   special,
		Length:    length,
	}

	pw, err := pwo.GeneratePassword()
	if err != nil {
		return err
	}

	html := `
<div class="password">
    <p class="mb-4" id="password-display"><span id="password">{{ .Password }}</span></p>
    <button onclick="copyToClipboard()">
        <svg xmlns="http://www.w3.org/2000/svg"
             width="32"
             height="32"
             viewBox="0 0 24 24">
             <path fill="currentColor"
                d="M9.5 2A1.5 1.5 0 0 0 8 3.5v1A1.5 1.5 0 0 0 9.5 6h5A1.5 1.5 0 0 0 16 4.5v-1A1.5 1.5 0 0 0 14.5 2z"/><path fill="currentColor" fill-rule="evenodd" d="M6.5 4.037c-1.258.07-2.052.27-2.621.84C3 5.756 3 7.17 3 9.998v6c0 2.829 0 4.243.879 5.122c.878.878 2.293.878 5.121.878h6c2.828 0 4.243 0 5.121-.878c.879-.88.879-2.293.879-5.122v-6c0-2.828 0-4.242-.879-5.121c-.569-.57-1.363-.77-2.621-.84V4.5a3 3 0 0 1-3 3h-5a3 3 0 0 1-3-3zM7 9.75a.75.75 0 0 0 0 1.5h.5a.75.75 0 0 0 0-1.5zm3.5 0a.75.75 0 0 0 0 1.5H17a.75.75 0 0 0 0-1.5zM7 13.25a.75.75 0 0 0 0 1.5h.5a.75.75 0 0 0 0-1.5zm3.5 0a.75.75 0 0 0 0 1.5H17a.75.75 0 0 0 0-1.5zM7 16.75a.75.75 0 0 0 0 1.5h.5a.75.75 0 0 0 0-1.5zm3.5 0a.75.75 0 0 0 0 1.5H17a.75.75 0 0 0 0-1.5z"
                clip-rule="evenodd"/>
        </svg>
    </button>
    <span id="copy-tooltip" style="visibility:hidden;">Copied!</span>
</div>
`

	tmpl, err := template.New("password").Parse(html)
	if err != nil {
		return err
	}

	response := models.Response{
		Password: pw,
	}

	err = tmpl.Execute(c.Response().Writer, response)
	if err != nil {
		return err
	}

	return nil
}
