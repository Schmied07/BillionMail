package prospect

import (
	"context"

	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/consts"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ReminderCreate(ctx context.Context, req *v1.ReminderCreateReq) (res *v1.ReminderCreateRes, err error) {
	res = &v1.ReminderCreateRes{}

	// Check if prospect exists
	prospectExists, err := prospect.ProspectExists(ctx, req.ProspectId)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to check prospect")))
		return
	}
	if !prospectExists {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Prospect not found")))
		return
	}

	// Create reminder
	id, err := prospect.CreateReminder(ctx, prospect.ReminderData{
		Title:      req.Title,
		ProspectId: req.ProspectId,
		Type:       req.Type,
		DueDate:    req.DueDate,
		Notes:      req.Notes,
	})
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to create reminder")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  "Create reminder: " + req.Title + " successfully",
		Data: req,
	})

	res.Data.Id = id
	res.SetSuccess(public.LangCtx(ctx, "Reminder created successfully"))
	return
}
