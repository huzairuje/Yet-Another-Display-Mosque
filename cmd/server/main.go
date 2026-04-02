package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type EventManager struct {
	mu          sync.Mutex
	subscribers map[chan string]bool
}

func NewEventManager() *EventManager {
	return &EventManager{
		subscribers: make(map[chan string]bool),
	}
}

func (em *EventManager) Subscribe() chan string {
	ch := make(chan string, 10)
	em.mu.Lock()
	em.subscribers[ch] = true
	em.mu.Unlock()
	return ch
}

func (em *EventManager) Unsubscribe(ch chan string) {
	em.mu.Lock()
	if _, ok := em.subscribers[ch]; ok {
		delete(em.subscribers, ch)
		close(ch)
	}
	em.mu.Unlock()
}

func (em *EventManager) Publish(message string) {
	em.mu.Lock()
	defer em.mu.Unlock()
	for ch := range em.subscribers {
		select {
		case ch <- message:
		default:
			// If the channel is full, drop the message
		}
	}
}

var eventManager = NewEventManager()

func getSettingsPath() string {
	return filepath.Join("data", "settings.json")
}

func readSettings() (map[string]interface{}, error) {
	data, err := os.ReadFile(getSettingsPath())
	if err != nil {
		return nil, err
	}
	var settings map[string]interface{}
	err = json.Unmarshal(data, &settings)
	if err != nil {
		return nil, err
	}
	return settings, nil
}

func handleGetSettings(c echo.Context) error {
	settings, err := readSettings()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal muat data"})
	}
	return c.JSON(http.StatusOK, settings)
}

func handlePostSettings(c echo.Context) error {
	var settings map[string]interface{}
	if err := c.Bind(&settings); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
	}

	data, err := json.MarshalIndent(settings, "", "  ")
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal serialize data"})
	}

	err = os.MkdirAll("data", os.ModePerm)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal buat folder data"})
	}

	err = os.WriteFile(getSettingsPath(), data, 0644)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal simpan data"})
	}

	eventManager.Publish("update")
	return c.JSON(http.StatusOK, map[string]bool{"success": true})
}

func handleEvents(c echo.Context) error {
	c.Response().Header().Set("Content-Type", "text/event-stream")
	c.Response().Header().Set("Cache-Control", "no-cache")
	c.Response().Header().Set("Connection", "keep-alive")

	ch := eventManager.Subscribe()
	defer eventManager.Unsubscribe(ch)

	ticker := time.NewTicker(20 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case msg, ok := <-ch:
			if !ok {
				return nil
			}
			if msg == "update" {
				fmt.Fprintf(c.Response(), "data: update\n\n")
				c.Response().Flush()
			}
		case <-ticker.C:
			fmt.Fprintf(c.Response(), ": ping\n\n")
			c.Response().Flush()
		case <-c.Request().Context().Done():
			return nil
		}
	}
}

func handleUpload(c echo.Context) error {
	file, err := c.FormFile("file")
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Gak ada file bray!"})
	}

	// VALIDASI: Cuma boleh gambar & maksimal 5MB
	allowedTypes := map[string]bool{
		"image/jpeg": true,
		"image/png":  true,
		"image/webp": true,
	}

	contentType := file.Header.Get("Content-Type")
	if !allowedTypes[contentType] {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Maaf, cuma boleh upload gambar (JPG/PNG/WEBP)"})
	}

	if file.Size > 5*1024*1024 {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Kegedean bray! Maksimal 5MB aja."})
	}

	src, err := file.Open()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal buka file"})
	}
	defer src.Close()

	ext := filepath.Ext(file.Filename)
	fileName := fmt.Sprintf("%d-%d%s", time.Now().UnixMilli(), time.Now().UnixNano()%1000000000, ext)
	filePath := filepath.Join("static", "uploads", fileName)

	err = os.MkdirAll(filepath.Join("static", "uploads"), os.ModePerm)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal buat folder upload"})
	}

	dst, err := os.Create(filePath)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal simpen file"})
	}
	defer dst.Close()

	if _, err = io.Copy(dst, src); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal nulis file"})
	}

	return c.JSON(http.StatusOK, map[string]string{"fileName": fmt.Sprintf("/uploads/%s", fileName)})
}

func handleDeleteUpload(c echo.Context) error {
	var req struct {
		FileName string `json:"fileName"`
	}
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request"})
	}

	if req.FileName == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "fileName missing"})
	}

	// Security check to prevent directory traversal
	if filepath.IsAbs(req.FileName) || filepath.Clean("/"+req.FileName) != "/"+req.FileName {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid path"})
	}

	filePath := filepath.Join("static", req.FileName)
	err := os.Remove(filePath)
	if err != nil && !os.IsNotExist(err) {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal hapus file"})
	}

	return c.JSON(http.StatusOK, map[string]bool{"success": true})
}

func main() {
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// API Routes
	api := e.Group("/api")
	api.GET("/settings", handleGetSettings)
	api.POST("/settings", handlePostSettings)
	api.GET("/events", handleEvents)
	api.POST("/upload", handleUpload)
	api.DELETE("/upload", handleDeleteUpload)

	// Static Files serving uploads
	e.Static("/uploads", filepath.Join("static", "uploads"))

	// Serve the pre-built frontend files
	// If a file is not found (like /admin), Echo will try to serve index.html (SPA fallback)
	e.Use(middleware.StaticWithConfig(middleware.StaticConfig{
		Root:   "build",
		Index:  "index.html",
		HTML5:  true,
		Browse: false,
	}))

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	host := os.Getenv("HOST")
	if host == "" {
		host = "0.0.0.0"
	}

	address := fmt.Sprintf("%s:%s", host, port)
	e.Logger.Fatal(e.Start(address))
}