package prospect

import (
	v1 "billionmail-core/api/prospect/v1"
	"billionmail-core/internal/service/prospect"
	"billionmail-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ProspectStats(ctx context.Context, req *v1.ProspectStatsReq) (res *v1.ProspectStatsRes, err error) {
	res = &v1.ProspectStatsRes{}

	stats, err := prospect.GetProspectStats(ctx)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to get statistics")))
		return
	}

	res.Data.TotalCount = stats.TotalCount
	res.Data.TotalValue = stats.TotalValue
	res.Data.AverageScore = stats.AverageScore
	res.Data.ConversionRate = stats.ConversionRate
	res.Data.StatusBreakdown = stats.StatusBreakdown
	res.Data.SourceBreakdown = stats.SourceBreakdown
	res.SetSuccess(public.LangCtx(ctx, "Success"))
	return
}
