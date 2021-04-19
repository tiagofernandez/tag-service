package main

import (
	"github.com/brazur/tag-server/api"

	"time"

	"github.com/labstack/echo/v4"
	mw "github.com/labstack/echo/v4/middleware"
)

func main() {
	e := echo.New()

	// Log the information about each HTTP request.
	e.Use(mw.Logger())

	// Recover from panic, print stack trace and handle the control to HTTPErrorHandler.
	e.Use(mw.Recover())

	// Limit the application to a number of requests/sec using the default in-memory store.
	e.Use(mw.RateLimiter(mw.NewRateLimiterMemoryStore(20)))

	// Enable secure cross-domain data transfers.
	e.Use(mw.CORS())

	// Protect against XSS, content type sniffing, clickjacking, insecure connection, etc.
	e.Use(mw.Secure())

	// Compress HTTP responses using Gzip compression scheme.
	e.Use(mw.Gzip())

	// Decompresses HTTP request if Content-Encoding header is set to gzip
	e.Use(mw.Decompress())

	// Timeout at a long running operation within a predefined period.
	e.Use(mw.TimeoutWithConfig(mw.TimeoutConfig{
		Timeout: 30 * time.Second,
	}))

	// Serve the web application and register API routes.
	e.Static("/", "web/build")
	api.RegisterRoutes(e)

	e.Logger.Fatal(e.Start(":6060"))
}
