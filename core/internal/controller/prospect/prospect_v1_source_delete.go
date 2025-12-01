package prospect

import (
	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/consts"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) SourceDelete(ctx context.Context, req *v1.SourceDeleteReq) (res *v1.SourceDeleteRes, err error) {
	res = &v1.SourceDeleteRes{}

	// Check if source exists
	source, err := prospect.GetSourceById(ctx, req.Id)
	if err != nil || source == nil {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Source not found")))
		return
	}

	// Check if source has prospects
	count, err := prospect.CountProspectsBySource(ctx, req.Id)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to check source usage")))
		return
	}
	if count > 0 {
		res.SetError(gerror.New(public.LangCtx(ctx, "Cannot delete source with existing prospects")))
		return
	}

	// Delete source
	err = prospect.DeleteSource(ctx, req.Id)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to delete source")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  "Delete prospect source: " + source.Name + " successfully",
		Data: req,
	})

	res.SetSuccess(public.LangCtx(ctx, "Source deleted successfully"))
	return
}
