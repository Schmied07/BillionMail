package prospect

import (
	"context"

	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/consts"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ReminderDelete(ctx context.Context, req *v1.ReminderDeleteReq) (res *v1.ReminderDeleteRes, err error) {
	res = &v1.ReminderDeleteRes{}

	if len(req.Ids) == 0 {
		res.SetError(gerror.New(public.LangCtx(ctx, "No reminder IDs provided")))
		return
	}

	// Delete reminders
	err = prospect.DeleteReminders(ctx, req.Ids)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to delete reminders")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  "Delete reminders successfully",
		Data: req,
	})

	res.SetSuccess(public.LangCtx(ctx, "Reminders deleted successfully"))
	return
}
