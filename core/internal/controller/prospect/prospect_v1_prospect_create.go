package prospect

import (
	v1 "billionmail-core/api/prospect/v1"
	"billionmail-core/internal/consts"
	"billionmail-core/internal/service/prospect"
	"billionmail-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
)

func (c *ControllerV1) ProspectCreate(ctx context.Context, req *v1.ProspectCreateReq) (res *v1.ProspectCreateRes, err error) {
	res = &v1.ProspectCreateRes{}

	// Check if source exists
	source, err := prospect.GetSourceById(ctx, req.SourceId)
	if err != nil || source == nil {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Source not found")))
		return
	}

	// Check if email already exists
	exists, err := prospect.EmailExists(ctx, req.Email, 0)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to check email")))
		return
	}
	if exists {
		res.SetError(gerror.New(public.LangCtx(ctx, "Email already exists")))
		return
	}

	// Use source default value if no value provided
	value := req.Value
	if value == 0 {
		value = source.DefaultValue
	}

	// Create prospect
	id, err := prospect.CreateProspect(ctx, prospect.ProspectData{
		Company:  req.Company,
		Contact:  req.Contact,
		Email:    req.Email,
		Phone:    req.Phone,
		Value:    value,
		Score:    req.Score,
		Status:   req.Status,
		Tags:     req.Tags,
		Notes:    req.Notes,
		SourceId: req.SourceId,
	})
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to create prospect")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  "Create prospect: " + req.Company + " (" + req.Email + ") successfully",
		Data: req,
	})

	res.Data.Id = id
	res.SetSuccess(public.LangCtx(ctx, "Prospect created successfully"))
	return
}
