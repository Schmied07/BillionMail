package prospect

import (
	"context"
	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/service/prospect"
)

func (c *ControllerV1) ReminderList(ctx context.Context, req *v1.ReminderListReq) (res *v1.ReminderListRes, err error) {
	res = &v1.ReminderListRes{}

	total, list, err := prospect.GetReminderList(ctx, prospect.ReminderListParams{
		Page:       req.Page,
		PageSize:   req.PageSize,
		ProspectId: req.ProspectId,
		Completed:  req.Completed,
		Type:       req.Type,
	})
	if err != nil {
		res.SetError(err)
		return
	}

	res.Data.Total = total
	res.Data.List = list
	res.SetSuccess("")
	return
}
