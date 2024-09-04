package main

import (
	"github.com/jgndev/pwbot/internal/application"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	// instantiate a new server
	e := echo.New()

	// enable gzip compression
	e.Use(middleware.GzipWithConfig(middleware.GzipConfig{
		Level: 5,
	}))

	// static assets
	e.Static("/public", "public")
	e.File("/favicon.ico", "public/img/favicon.ico")
	e.File("/robots.txt", "public/txt/robots.txt")

	// handlers
	e.GET("/", application.Home)
	e.POST("/password", application.NewPassword)

	// start server
	e.Logger.Fatal(e.Start(":8080"))
}
