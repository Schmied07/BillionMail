package prospect

import (
	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/consts"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
	"github.com/gogf/gf/v2/frame/g"
)

func (c *ControllerV1) SourceUpdate(ctx context.Context, req *v1.SourceUpdateReq) (res *v1.SourceUpdateRes, err error) {
	res = &v1.SourceUpdateRes{}

	// Check if source exists
	source, err := prospect.GetSourceById(ctx, req.Id)
	if err != nil || source == nil {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Source not found")))
		return
	}

	// Check if name already exists (exclude current)
	if req.Name != "" && req.Name != source.Name {
		exists, err := prospect.SourceNameExists(ctx, req.Name, req.Id)
		if err != nil {
			res.SetError(gerror.New(public.LangCtx(ctx, "Failed to check source name")))
			return res, nil
		}
		if exists {
			res.SetError(gerror.New(public.LangCtx(ctx, "Source name already exists")))
			return res, nil
		}
	}

	// Build update data
	updateData := g.Map{}
	if req.Name != "" {
		updateData["name"] = req.Name
	}
	if req.DefaultValue >= 0 {
		updateData["default_value"] = req.DefaultValue
	}
	if req.Description != "" {
		updateData["description"] = req.Description
	}
	if req.Color != "" {
		updateData["color"] = req.Color
	}

	err = prospect.UpdateSource(ctx, req.Id, updateData)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to update source")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  "Update prospect source: " + source.Name + " successfully",
		Data: req,
	})

	res.SetSuccess(public.LangCtx(ctx, "Source updated successfully"))
	return
}
