package prospect

import (
	v1 "billionmail-core/api/prospect/v1"
	"billionmail-core/internal/service/prospect"
	"billionmail-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ProspectList(ctx context.Context, req *v1.ProspectListReq) (res *v1.ProspectListRes, err error) {
	res = &v1.ProspectListRes{}

	page := req.Page
	if page <= 0 {
		page = 1
	}
	pageSize := req.PageSize
	if pageSize <= 0 {
		pageSize = 20
	}

	list, total, err := prospect.GetProspectsWithPage(ctx, prospect.ProspectListParams{
		Page:      page,
		PageSize:  pageSize,
		Keyword:   req.Keyword,
		Status:    req.Status,
		SourceId:  req.SourceId,
		SortBy:    req.SortBy,
		SortOrder: req.SortOrder,
	})
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to get prospect list")))
		return
	}

	res.Data.List = list
	res.Data.Total = total
	res.SetSuccess(public.LangCtx(ctx, "Success"))
	return
}
