package main

import (
	"rapatln_backend/config"
	"rapatln_backend/controllers"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	// CORS configuration
	r.Use(cors.Default())

	// Connect to database
	config.ConnectDatabase()

	// Routes
	api := r.Group("/api")
	{
		// Auth
		api.POST("/register", controllers.Register)
		api.POST("/login", controllers.Login)

		// Meetings
		api.GET("/meetings", controllers.GetMeetings)
		api.GET("/meetings/:id", controllers.GetMeeting)
		api.POST("/meetings", controllers.CreateMeeting)
		api.PATCH("/meetings/:id", controllers.UpdateMeeting)
		api.DELETE("/meetings/:id", controllers.DeleteMeeting)

		// User
		api.GET("/user/:id", controllers.GetUser)
		api.PUT("/user/:id", controllers.UpdateUser)
	}

	// Run the server
	r.Run(":8080")
}
