package controllers

import (
	"context"
	"net/http"
	"rapatln_backend/config"
	"rapatln_backend/models"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// GET /meetings
func GetMeetings(c *gin.Context) {
	meetings := []models.Meeting{}
	collection := config.GetCollection("meetings")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer cursor.Close(ctx)

	for cursor.Next(ctx) {
		var meeting models.Meeting
		cursor.Decode(&meeting)
		meetings = append(meetings, meeting)
	}

	c.JSON(http.StatusOK, gin.H{"data": meetings})
}

// GET /meetings/:id
func GetMeeting(c *gin.Context) {
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	var meeting models.Meeting
	collection := config.GetCollection("meetings")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	err = collection.FindOne(ctx, bson.M{"_id": id}).Decode(&meeting)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Record not found!"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": meeting})
}

// POST /meetings
func CreateMeeting(c *gin.Context) {
	var input models.Meeting
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	input.ID = primitive.NewObjectID()
	collection := config.GetCollection("meetings")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := collection.InsertOne(ctx, input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": input})
}

// PATCH /meetings/:id
func UpdateMeeting(c *gin.Context) {
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	collection := config.GetCollection("meetings")

	var input models.Meeting
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	updateData := bson.M{}
	if input.Title != "" {
		updateData["title"] = input.Title
	}
	if input.Date != "" {
		updateData["date"] = input.Date
	}
	if input.Location != "" {
		updateData["location"] = input.Location
	}
	if input.Discussion != "" {
		updateData["discussion"] = input.Discussion
	}
	if input.Decision != "" {
		updateData["decision"] = input.Decision
	}
	if input.FollowUp != "" {
		updateData["followUp"] = input.FollowUp
	}

	update := bson.M{"$set": updateData}

	_, err = collection.UpdateOne(ctx, bson.M{"_id": id}, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	input.ID = id
	c.JSON(http.StatusOK, gin.H{"data": input})
}

// DELETE /meetings/:id
func DeleteMeeting(c *gin.Context) {
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	collection := config.GetCollection("meetings")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err = collection.DeleteOne(ctx, bson.M{"_id": id})
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to delete"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": true})
}
