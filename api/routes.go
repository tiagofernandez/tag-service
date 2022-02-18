package api

import (
	"net/http"
	"os"

	"github.com/brazur/tag-service/api/fixtures"
	"github.com/labstack/echo/v4"
)

// RegisterRoutes defines routes in the API group.
func RegisterRoutes(e *echo.Echo) {
	api := e.Group("/api")
	api.GET("/fixtures/:name", fixtures.GetAll).Name = "fixtures"
	api.GET("/health-check", healthCheck).Name = "health-check"
}

func healthCheck(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]string{
		"env": os.Getenv("ENV"),
	})
}
