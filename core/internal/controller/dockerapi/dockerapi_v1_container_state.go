package dockerapi

import (
	"tetrisnewsemailing-core/internal/service/public"
	"context"

	"tetrisnewsemailing-core/api/dockerapi/v1"
)

func (c *ControllerV1) ContainerState(ctx context.Context, req *v1.ContainerStateReq) (res *v1.ContainerStateRes, err error) {
	res = &v1.ContainerStateRes{}

	res.Data, err = public.DockerApiFromCtx(ctx).GetContainerStats(ctx, req.ContainerID)

	res.SetSuccess(public.LangCtx(ctx, "Success"))

	return
}
