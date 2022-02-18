package fixtures

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
)

func init() {
	fixturePaths["feature-flags"] = "../../fixtures/feature-flags.json"
}

func TestGetAll(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rec := httptest.NewRecorder()

	c := echo.New().NewContext(req, rec)
	c.SetPath("/api/fixtures/:name")
	c.SetParamNames("name")
	c.SetParamValues("feature-flags")

	if assert.NoError(t, GetAll(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)
	}
}

func TestGetAll_NotFound(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rec := httptest.NewRecorder()

	c := echo.New().NewContext(req, rec)
	c.SetPath("/api/fixtures/:name")
	c.SetParamNames("name")
	c.SetParamValues("unknown")

	if assert.NoError(t, GetAll(c)) {
		assert.Equal(t, http.StatusNotFound, rec.Code)
	}
}
