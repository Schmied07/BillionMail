// =================================================================================
// Code generated and maintained by GoFrame CLI tool. DO NOT EDIT.
// =================================================================================

package prospect

import (
	"context"

	"tetrisnewsemailing-core/api/prospect/v1"
)

type IProspectV1 interface {
	// Source APIs
	SourceList(ctx context.Context, req *v1.SourceListReq) (res *v1.SourceListRes, err error)
	SourceAll(ctx context.Context, req *v1.SourceAllReq) (res *v1.SourceAllRes, err error)
	SourceCreate(ctx context.Context, req *v1.SourceCreateReq) (res *v1.SourceCreateRes, err error)
	SourceUpdate(ctx context.Context, req *v1.SourceUpdateReq) (res *v1.SourceUpdateRes, err error)
	SourceDelete(ctx context.Context, req *v1.SourceDeleteReq) (res *v1.SourceDeleteRes, err error)

	// Prospect APIs
	ProspectList(ctx context.Context, req *v1.ProspectListReq) (res *v1.ProspectListRes, err error)
	ProspectCreate(ctx context.Context, req *v1.ProspectCreateReq) (res *v1.ProspectCreateRes, err error)
	ProspectUpdate(ctx context.Context, req *v1.ProspectUpdateReq) (res *v1.ProspectUpdateRes, err error)
	ProspectDelete(ctx context.Context, req *v1.ProspectDeleteReq) (res *v1.ProspectDeleteRes, err error)
	ProspectGet(ctx context.Context, req *v1.ProspectGetReq) (res *v1.ProspectGetRes, err error)

	// Import APIs
	ImportPreview(ctx context.Context, req *v1.ImportPreviewReq) (res *v1.ImportPreviewRes, err error)
	ImportProspects(ctx context.Context, req *v1.ImportProspectsReq) (res *v1.ImportProspectsRes, err error)

	// Stats APIs
	ProspectStats(ctx context.Context, req *v1.ProspectStatsReq) (res *v1.ProspectStatsRes, err error)

	// Reminder APIs
	ReminderList(ctx context.Context, req *v1.ReminderListReq) (res *v1.ReminderListRes, err error)
	ReminderCreate(ctx context.Context, req *v1.ReminderCreateReq) (res *v1.ReminderCreateRes, err error)
	ReminderUpdate(ctx context.Context, req *v1.ReminderUpdateReq) (res *v1.ReminderUpdateRes, err error)
	ReminderDelete(ctx context.Context, req *v1.ReminderDeleteReq) (res *v1.ReminderDeleteRes, err error)
	ReminderGet(ctx context.Context, req *v1.ReminderGetReq) (res *v1.ReminderGetRes, err error)
}
