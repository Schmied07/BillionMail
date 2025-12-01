package v1

import (
	"billionmail-core/utility/types/api_v1"

	"github.com/gogf/gf/v2/frame/g"
)

// ProspectSource represents a prospect source with value configuration
type ProspectSource struct {
	Id          int    `json:"id"          dc:"Source ID"`
	Name        string `json:"name"        dc:"Source Name"`
	DefaultValue int   `json:"default_value" dc:"Default Value for prospects from this source"`
	Description string `json:"description" dc:"Description"`
	Color       string `json:"color"       dc:"Color for UI display"`
	CreateTime  int    `json:"create_time" dc:"Create Time"`
	UpdateTime  int    `json:"update_time" dc:"Update Time"`
}

// Prospect represents a sales prospect
type Prospect struct {
	Id          int               `json:"id"          dc:"Prospect ID"`
	Company     string            `json:"company"     dc:"Company Name"`
	Contact     string            `json:"contact"     dc:"Contact Name"`
	Email       string            `json:"email"       dc:"Email Address"`
	Phone       string            `json:"phone"       dc:"Phone Number"`
	Value       int               `json:"value"       dc:"Estimated Value"`
	Score       int               `json:"score"       dc:"Score (1-5)"`
	Status      string            `json:"status"      dc:"Status (new/contacted/qualified/negotiation/converted)"`
	Tags        []string          `json:"tags"        dc:"Tags"`
	Notes       string            `json:"notes"       dc:"Notes"`
	SourceId    int               `json:"source_id"   dc:"Source ID"`
	SourceName  string            `json:"source_name" dc:"Source Name"`
	LastContact int               `json:"last_contact" dc:"Last Contact Time"`
	CreateTime  int               `json:"create_time" dc:"Create Time"`
	UpdateTime  int               `json:"update_time" dc:"Update Time"`
	Attribs     map[string]string `json:"attribs"     dc:"Custom Attributes"`
}

// ========== Source APIs ==========

type SourceListReq struct {
	g.Meta        `path:"/prospect/source/list" method:"get" tags:"Prospect" summary:"List prospect sources"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Page          int    `json:"page" dc:"Page" d:"1"`
	PageSize      int    `json:"page_size" dc:"Page size" d:"20"`
	Keyword       string `json:"keyword" dc:"Search keyword"`
}

type SourceListRes struct {
	api_v1.StandardRes
	Data struct {
		Total int               `json:"total" dc:"Total Count"`
		List  []*ProspectSource `json:"list" dc:"Source list"`
	} `json:"data"`
}

type SourceAllReq struct {
	g.Meta        `path:"/prospect/source/all" method:"get" tags:"Prospect" summary:"Get all prospect sources"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
}

type SourceAllRes struct {
	api_v1.StandardRes
	Data struct {
		List []*ProspectSource `json:"list" dc:"Source list"`
	} `json:"data"`
}

type SourceCreateReq struct {
	g.Meta        `path:"/prospect/source/create" method:"post" tags:"Prospect" summary:"Create a new prospect source"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Name          string `json:"name" v:"required|max-length:100" dc:"Source Name"`
	DefaultValue  int    `json:"default_value" v:"min:0" dc:"Default Value"`
	Description   string `json:"description" dc:"Description"`
	Color         string `json:"color" dc:"Color"`
}

type SourceCreateRes struct {
	api_v1.StandardRes
	Data struct {
		Id int `json:"id" dc:"Created Source ID"`
	} `json:"data"`
}

type SourceUpdateReq struct {
	g.Meta        `path:"/prospect/source/update" method:"post" tags:"Prospect" summary:"Update a prospect source"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Id            int    `json:"id" v:"required|min:1" dc:"Source ID"`
	Name          string `json:"name" v:"max-length:100" dc:"Source Name"`
	DefaultValue  int    `json:"default_value" v:"min:0" dc:"Default Value"`
	Description   string `json:"description" dc:"Description"`
	Color         string `json:"color" dc:"Color"`
}

type SourceUpdateRes struct {
	api_v1.StandardRes
}

type SourceDeleteReq struct {
	g.Meta        `path:"/prospect/source/delete" method:"post" tags:"Prospect" summary:"Delete a prospect source"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Id            int    `json:"id" v:"required|min:1" dc:"Source ID"`
}

type SourceDeleteRes struct {
	api_v1.StandardRes
}

// ========== Prospect APIs ==========

type ProspectListReq struct {
	g.Meta        `path:"/prospect/list" method:"get" tags:"Prospect" summary:"List prospects"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Page          int    `json:"page" dc:"Page" d:"1"`
	PageSize      int    `json:"page_size" dc:"Page size" d:"20"`
	Keyword       string `json:"keyword" dc:"Search keyword"`
	Status        string `json:"status" dc:"Filter by status"`
	SourceId      int    `json:"source_id" dc:"Filter by source"`
	SortBy        string `json:"sort_by" v:"in:create_time,value,score,last_contact" dc:"Sort field" d:"create_time"`
	SortOrder     string `json:"sort_order" v:"in:asc,desc" dc:"Sort order" d:"desc"`
}

type ProspectListRes struct {
	api_v1.StandardRes
	Data struct {
		Total int         `json:"total" dc:"Total Count"`
		List  []*Prospect `json:"list" dc:"Prospect list"`
	} `json:"data"`
}

type ProspectCreateReq struct {
	g.Meta        `path:"/prospect/create" method:"post" tags:"Prospect" summary:"Create a new prospect"`
	Authorization string   `json:"authorization" dc:"Authorization" in:"header"`
	Company       string   `json:"company" v:"required|max-length:255" dc:"Company Name"`
	Contact       string   `json:"contact" v:"required|max-length:255" dc:"Contact Name"`
	Email         string   `json:"email" v:"required|email" dc:"Email Address"`
	Phone         string   `json:"phone" dc:"Phone Number"`
	Value         int      `json:"value" v:"min:0" dc:"Estimated Value"`
	Score         int      `json:"score" v:"min:1|max:5" dc:"Score (1-5)" d:"3"`
	Status        string   `json:"status" v:"in:new,contacted,qualified,negotiation,converted" dc:"Status" d:"new"`
	Tags          []string `json:"tags" dc:"Tags"`
	Notes         string   `json:"notes" dc:"Notes"`
	SourceId      int      `json:"source_id" v:"required|min:1" dc:"Source ID"`
}

type ProspectCreateRes struct {
	api_v1.StandardRes
	Data struct {
		Id int `json:"id" dc:"Created Prospect ID"`
	} `json:"data"`
}

type ProspectUpdateReq struct {
	g.Meta        `path:"/prospect/update" method:"post" tags:"Prospect" summary:"Update a prospect"`
	Authorization string   `json:"authorization" dc:"Authorization" in:"header"`
	Id            int      `json:"id" v:"required|min:1" dc:"Prospect ID"`
	Company       string   `json:"company" dc:"Company Name"`
	Contact       string   `json:"contact" dc:"Contact Name"`
	Email         string   `json:"email" dc:"Email Address"`
	Phone         string   `json:"phone" dc:"Phone Number"`
	Value         int      `json:"value" dc:"Estimated Value"`
	Score         int      `json:"score" v:"min:1|max:5" dc:"Score (1-5)"`
	Status        string   `json:"status" v:"in:new,contacted,qualified,negotiation,converted" dc:"Status"`
	Tags          []string `json:"tags" dc:"Tags"`
	Notes         string   `json:"notes" dc:"Notes"`
	SourceId      int      `json:"source_id" dc:"Source ID"`
	LastContact   int      `json:"last_contact" dc:"Last Contact Time"`
}

type ProspectUpdateRes struct {
	api_v1.StandardRes
}

type ProspectDeleteReq struct {
	g.Meta        `path:"/prospect/delete" method:"post" tags:"Prospect" summary:"Delete prospects"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Ids           []int  `json:"ids" v:"required" dc:"Prospect IDs"`
}

type ProspectDeleteRes struct {
	api_v1.StandardRes
	Data struct {
		DeletedCount int `json:"deleted_count" dc:"Number of deleted prospects"`
	} `json:"data"`
}

type ProspectGetReq struct {
	g.Meta        `path:"/prospect/get" method:"get" tags:"Prospect" summary:"Get prospect details"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	Id            int    `json:"id" v:"required|min:1" dc:"Prospect ID"`
}

type ProspectGetRes struct {
	api_v1.StandardRes
	Data *Prospect `json:"data" dc:"Prospect details"`
}

// ========== Import APIs ==========

type ImportPreviewReq struct {
	g.Meta        `path:"/prospect/import/preview" method:"post" tags:"Prospect" summary:"Preview CSV import with column detection"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
	FileData      string `json:"file_data" v:"required" dc:"CSV file content (base64 or raw)"`
	Delimiter     string `json:"delimiter" dc:"CSV delimiter" d:","`
}

type CSVColumn struct {
	Index      int    `json:"index"       dc:"Column index"`
	Name       string `json:"name"        dc:"Column name from CSV header"`
	SampleData string `json:"sample_data" dc:"Sample data from first row"`
}

type ImportPreviewRes struct {
	api_v1.StandardRes
	Data struct {
		Columns    []*CSVColumn `json:"columns"     dc:"Detected CSV columns"`
		TotalRows  int          `json:"total_rows"  dc:"Total number of data rows"`
		SampleRows [][]string   `json:"sample_rows" dc:"First 5 sample rows"`
	} `json:"data"`
}

type FieldMapping struct {
	CsvColumn  string `json:"csv_column"  dc:"CSV column name"`
	AppField   string `json:"app_field"   dc:"Application field name"`
}

type ImportProspectsReq struct {
	g.Meta        `path:"/prospect/import" method:"post" tags:"Prospect" summary:"Import prospects from CSV"`
	Authorization string          `json:"authorization" dc:"Authorization" in:"header"`
	SourceId      int             `json:"source_id" v:"required|min:1" dc:"Source ID"`
	FileData      string          `json:"file_data" v:"required" dc:"CSV file content"`
	Delimiter     string          `json:"delimiter" dc:"CSV delimiter" d:","`
	Mapping       []*FieldMapping `json:"mapping" v:"required" dc:"Field mapping configuration"`
	DefaultStatus string          `json:"default_status" v:"in:new,contacted,qualified,negotiation,converted" dc:"Default status for imported prospects" d:"new"`
	DefaultScore  int             `json:"default_score" v:"min:1|max:5" dc:"Default score" d:"3"`
}

type ImportProspectsRes struct {
	api_v1.StandardRes
	Data struct {
		ImportedCount int `json:"imported_count" dc:"Number of successfully imported prospects"`
		SkippedCount  int `json:"skipped_count"  dc:"Number of skipped (duplicate) prospects"`
		ErrorCount    int `json:"error_count"    dc:"Number of rows with errors"`
	} `json:"data"`
}

// ========== Stats APIs ==========

type ProspectStatsReq struct {
	g.Meta        `path:"/prospect/stats" method:"get" tags:"Prospect" summary:"Get prospect statistics"`
	Authorization string `json:"authorization" dc:"Authorization" in:"header"`
}

type ProspectStatsRes struct {
	api_v1.StandardRes
	Data struct {
		TotalCount      int            `json:"total_count"      dc:"Total prospects"`
		TotalValue      int            `json:"total_value"      dc:"Total pipeline value"`
		AverageScore    float64        `json:"average_score"    dc:"Average score"`
		ConversionRate  float64        `json:"conversion_rate"  dc:"Conversion rate"`
		StatusBreakdown map[string]int `json:"status_breakdown" dc:"Count by status"`
		SourceBreakdown map[string]int `json:"source_breakdown" dc:"Count by source"`
	} `json:"data"`
}
