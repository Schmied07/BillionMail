package prospect

import (
	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) SourceAll(ctx context.Context, req *v1.SourceAllReq) (res *v1.SourceAllRes, err error) {
	res = &v1.SourceAllRes{}

	list, err := prospect.GetAllSources(ctx)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to get sources")))
		return
	}

	res.Data.List = list
	res.SetSuccess(public.LangCtx(ctx, "Success"))
	return
}
