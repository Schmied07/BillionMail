package prospect

import (
	v1 "billionmail-core/api/prospect/v1"
	"billionmail-core/internal/consts"
	"billionmail-core/internal/service/prospect"
	"billionmail-core/internal/service/public"
	"context"

	"github.com/gogf/gf/v2/errors/gerror"
	"github.com/gogf/gf/v2/frame/g"
)

func (c *ControllerV1) ProspectUpdate(ctx context.Context, req *v1.ProspectUpdateReq) (res *v1.ProspectUpdateRes, err error) {
	res = &v1.ProspectUpdateRes{}

	// Check if prospect exists
	existingProspect, err := prospect.GetProspectById(ctx, req.Id)
	if err != nil || existingProspect == nil {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Prospect not found")))
		return
	}

	// Check if email already exists (exclude current)
	if req.Email != "" && req.Email != existingProspect.Email {
		exists, err := prospect.EmailExists(ctx, req.Email, req.Id)
		if err != nil {
			res.SetError(gerror.New(public.LangCtx(ctx, "Failed to check email")))
			return res, nil
		}
		if exists {
			res.SetError(gerror.New(public.LangCtx(ctx, "Email already exists")))
			return res, nil
		}
	}

	// Check if source exists
	if req.SourceId > 0 {
		source, err := prospect.GetSourceById(ctx, req.SourceId)
		if err != nil || source == nil {
			res.SetError(gerror.New(public.LangCtx(ctx, "Source not found")))
			return res, nil
		}
	}

	// Build update data
	updateData := g.Map{}
	if req.Company != "" {
		updateData["company"] = req.Company
	}
	if req.Contact != "" {
		updateData["contact"] = req.Contact
	}
	if req.Email != "" {
		updateData["email"] = req.Email
	}
	if req.Phone != "" {
		updateData["phone"] = req.Phone
	}
	if req.Value >= 0 {
		updateData["value"] = req.Value
	}
	if req.Score >= 1 && req.Score <= 5 {
		updateData["score"] = req.Score
	}
	if req.Status != "" {
		updateData["status"] = req.Status
	}
	if req.Tags != nil {
		updateData["tags"] = req.Tags
	}
	if req.Notes != "" {
		updateData["notes"] = req.Notes
	}
	if req.SourceId > 0 {
		updateData["source_id"] = req.SourceId
	}
	if req.LastContact > 0 {
		updateData["last_contact"] = req.LastContact
	}

	err = prospect.UpdateProspect(ctx, req.Id, updateData)
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to update prospect")))
		return
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  "Update prospect: " + existingProspect.Company + " (" + existingProspect.Email + ") successfully",
		Data: req,
	})

	res.SetSuccess(public.LangCtx(ctx, "Prospect updated successfully"))
	return
}
