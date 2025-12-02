package v1

import (
	"tetrisnewsemailing-core/utility/types/api_v1"

	"github.com/gogf/gf/v2/frame/g"
)

// Reminder represents a prospect reminder/follow-up
type Reminder struct {
	Id          int    `json:"id"           dc:"Reminder ID"`
	Title       string `json:"title"        dc:"Reminder Title"`
	ProspectId  int    `json:"prospect_id"  dc:"Prospect ID"`
	ProspectName string `json:"prospect_name" dc:"Prospect Name (Company)"`
	Type        string `json:"type"         dc:"Type (call/email/meeting/other)"`
	DueDate     int64  `json:"due_date"     dc:"Due Date (Unix timestamp)"`
	Notes       string `json:"notes"        dc:"Notes"`
	Completed   bool   `json:"completed"    dc:"Completed Status"`
	CreateTime  int    `json:"create_time"  dc:"Create Time"`
	UpdateTime  int    `json:"update_time"  dc:"Update Time"`
}

// ========== Reminder APIs ==========

type ReminderListReq struct {
	g.Meta        `path:"/prospect/reminder/list" method:"get" tags:"Prospect" summary:"List prospect reminders"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Page          int    `json:"page" dc:"Page" d:"1"`
	PageSize      int    `json:"page_size" dc:"Page size" d:"100"`
	ProspectId    int    `json:"prospect_id" dc:"Filter by prospect ID"`
	Completed     *bool  `json:"completed" dc:"Filter by completed status"`
	Type          string `json:"type" dc:"Filter by type"`
}

type ReminderListRes struct {
	api_v1.StandardRes
	Data struct {
		Total int         `json:"total" dc:"Total Count"`
		List  []*Reminder `json:"list" dc:"Reminder list"`
	} `json:"data"`
}

type ReminderCreateReq struct {
	g.Meta        `path:"/prospect/reminder/create" method:"post" tags:"Prospect" summary:"Create a new reminder"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Title         string `json:"title" v:"required|max-length:200" dc:"Reminder Title"`
	ProspectId    int    `json:"prospect_id" v:"required|min:1" dc:"Prospect ID"`
	Type          string `json:"type" v:"required|in:call,email,meeting,other" dc:"Type"`
	DueDate       int64  `json:"due_date" v:"required|min:0" dc:"Due Date (Unix timestamp)"`
	Notes         string `json:"notes" dc:"Notes"`
}

type ReminderCreateRes struct {
	api_v1.StandardRes
	Data struct {
		Id int `json:"id" dc:"Created Reminder ID"`
	} `json:"data"`
}

type ReminderUpdateReq struct {
	g.Meta        `path:"/prospect/reminder/update" method:"post" tags:"Prospect" summary:"Update a reminder"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Id            int    `json:"id" v:"required|min:1" dc:"Reminder ID"`
	Title         string `json:"title" v:"max-length:200" dc:"Reminder Title"`
	Type          string `json:"type" v:"in:call,email,meeting,other" dc:"Type"`
	DueDate       int64  `json:"due_date" v:"min:0" dc:"Due Date (Unix timestamp)"`
	Notes         string `json:"notes" dc:"Notes"`
	Completed     *bool  `json:"completed" dc:"Completed Status"`
}

type ReminderUpdateRes struct {
	api_v1.StandardRes
}

type ReminderDeleteReq struct {
	g.Meta        `path:"/prospect/reminder/delete" method:"post" tags:"Prospect" summary:"Delete reminders"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Ids           []int  `json:"ids" v:"required" dc:"Reminder IDs to delete"`
}

type ReminderDeleteRes struct {
	api_v1.StandardRes
}

type ReminderGetReq struct {
	g.Meta        `path:"/prospect/reminder/get" method:"get" tags:"Prospect" summary:"Get a reminder by ID"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Id            int    `json:"id" v:"required|min:1" dc:"Reminder ID"`
}

type ReminderGetRes struct {
	api_v1.StandardRes
	Data *Reminder `json:"data"`
}
