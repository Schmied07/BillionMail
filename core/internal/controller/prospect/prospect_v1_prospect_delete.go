package prospect

import (
	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/consts"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"
	"context"
	"fmt"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ProspectDelete(ctx context.Context, req *v1.ProspectDeleteReq) (res *v1.ProspectDeleteRes, err error) {
	res = &v1.ProspectDeleteRes{}

	if len(req.Ids) == 0 {
		res.SetError(gerror.New(public.LangCtx(ctx, "No prospect IDs provided")))
		return
	}

	// Delete prospects
	deletedCount, err := prospect.DeleteProspects(ctx, req.Ids)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to delete prospects")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  fmt.Sprintf("Delete %d prospects successfully", deletedCount),
		Data: req,
	})

	res.Data.DeletedCount = deletedCount
	res.SetSuccess(public.LangCtx(ctx, "Prospects deleted successfully"))
	return
}
