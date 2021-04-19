package api

import (
	"net/http"
	"os"

	"github.com/labstack/echo/v4"
)

// Register routes defined in the API module.
func RegisterRoutes(e *echo.Echo) {
	api := e.Group("/api")
	api.GET("/health-check", healthCheck).Name = "health-check"
}

func healthCheck(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]string{
		"env": os.Getenv("ENV"),
	})
}
