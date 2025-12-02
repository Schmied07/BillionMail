package prospect

import (
	"context"

	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/consts"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ReminderUpdate(ctx context.Context, req *v1.ReminderUpdateReq) (res *v1.ReminderUpdateRes, err error) {
	res = &v1.ReminderUpdateRes{}

	// Check if reminder exists
	reminderExists, err := prospect.ReminderExists(ctx, req.Id)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to check reminder")))
		return
	}
	if !reminderExists {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Reminder not found")))
		return
	}

	// Update reminder
	err = prospect.UpdateReminder(ctx, req.Id, prospect.ReminderUpdateData{
		Title:     req.Title,
		Type:      req.Type,
		DueDate:   req.DueDate,
		Notes:     req.Notes,
		Completed: req.Completed,
	})
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to update reminder")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  "Update reminder successfully",
		Data: req,
	})

	res.SetSuccess(public.LangCtx(ctx, "Reminder updated successfully"))
	return
}
