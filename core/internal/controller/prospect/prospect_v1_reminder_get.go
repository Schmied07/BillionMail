package prospect

import (
	"context"

	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ReminderGet(ctx context.Context, req *v1.ReminderGetReq) (res *v1.ReminderGetRes, err error) {
	res = &v1.ReminderGetRes{}

	reminder, err := prospect.GetReminderById(ctx, req.Id)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to get reminder")))
		return
	}

	if reminder == nil {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Reminder not found")))
		return
	}

	res.Data = reminder
	res.SetSuccess("")
	return
}
