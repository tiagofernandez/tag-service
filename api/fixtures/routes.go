// Package fixtures defines the API endpoints for the fixtures module.
package fixtures

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

// GetAll returns the requested fixtures as key-value pairs.
func GetAll(c echo.Context) error {
	name := c.Param("name")

	if name == "feature-flags" {
		return c.JSON(http.StatusOK, loadFeatureFlags())
	}
	return c.NoContent(http.StatusNotFound)
}
