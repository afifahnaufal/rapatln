package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Meeting struct {
	ID         primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Title      string             `bson:"title" json:"title"`
	Date       string             `bson:"date" json:"date"`
	Location   string             `bson:"location" json:"location"`
	Discussion string             `bson:"discussion" json:"discussion"`
	Decision   string             `bson:"decision" json:"decision"`
	FollowUp   string             `bson:"followUp" json:"followUp"`
}
