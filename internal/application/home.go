package application

import (
	"github.com/jgndev/pwbot/internal/views/pages"
	"github.com/labstack/echo/v4"
)

func Home(c echo.Context) error {
	return pages.Home().Render(c.Request().Context(), c.Response().Writer)
}
