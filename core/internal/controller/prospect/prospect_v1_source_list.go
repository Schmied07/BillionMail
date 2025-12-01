package prospect

import (
	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) SourceList(ctx context.Context, req *v1.SourceListReq) (res *v1.SourceListRes, err error) {
	res = &v1.SourceListRes{}

	page := req.Page
	if page <= 0 {
		page = 1
	}
	pageSize := req.PageSize
	if pageSize <= 0 {
		pageSize = 20
	}

	list, total, err := prospect.GetSourcesWithPage(ctx, page, pageSize, req.Keyword)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to get source list")))
		return
	}

	res.Data.List = list
	res.Data.Total = total
	res.SetSuccess(public.LangCtx(ctx, "Success"))
	return
}
