package prospect

import (
	v1 "billionmail-core/api/prospect/v1"
	"billionmail-core/internal/consts"
	"billionmail-core/internal/service/prospect"
	"billionmail-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) SourceCreate(ctx context.Context, req *v1.SourceCreateReq) (res *v1.SourceCreateRes, err error) {
	res = &v1.SourceCreateRes{}

	// Check if name already exists
	exists, err := prospect.SourceNameExists(ctx, req.Name, 0)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to check source name")))
		return
	}
	if exists {
		res.SetError(gerror.New(public.LangCtx(ctx, "Source name already exists")))
		return
	}

	// Create source
	id, err := prospect.CreateSource(ctx, req.Name, req.DefaultValue, req.Description, req.Color)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to create source")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  "Create prospect source: " + req.Name + " successfully",
		Data: req,
	})

	res.Data.Id = id
	res.SetSuccess(public.LangCtx(ctx, "Source created successfully"))
	return
}
