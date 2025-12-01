package prospect

import (
	v1 "billionmail-core/api/prospect/v1"
	"billionmail-core/internal/service/prospect"
	"billionmail-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ProspectGet(ctx context.Context, req *v1.ProspectGetReq) (res *v1.ProspectGetRes, err error) {
	res = &v1.ProspectGetRes{}

	p, err := prospect.GetProspectById(ctx, req.Id)
	if err != nil || p == nil {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Prospect not found")))
		return
	}

	res.Data = p
	res.SetSuccess(public.LangCtx(ctx, "Success"))
	return
}
