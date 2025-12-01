package prospect

import (
	v1 "billionmail-core/api/prospect/v1"
	billionmail-core/internal/service/public
	"bytes"
	"context"
	"encoding/base64"
	"encoding/csv"
	"io"
	"strings"

	"github.com/gogf/gf/v2/errors/gerror"
	"github.com/gogf/gf/v2/frame/g"
)

func (c *ControllerV1) ImportPreview(ctx context.Context, req *v1.ImportPreviewReq) (res *v1.ImportPreviewRes, err error) {
	res = &v1.ImportPreviewRes{}

	// Decode base64 if needed
	fileContent := req.FileData
	if strings.Contains(fileContent, "base64,") {
		parts := strings.SplitN(fileContent, "base64,", 2)
		if len(parts) == 2 {
			decoded, err := base64.StdEncoding.DecodeString(parts[1])
			if err != nil {
				res.SetError(gerror.New(public.LangCtx(ctx, "Invalid file encoding")))
				return res, nil
			}
			fileContent = string(decoded)
		}
	} else {
		// Try direct base64 decode
		if decoded, err := base64.StdEncoding.DecodeString(fileContent); err == nil {
			fileContent = string(decoded)
		}
	}

	delimiter := req.Delimiter
	if delimiter == "" {
		delimiter = ","
	}

	reader := csv.NewReader(bytes.NewReader([]byte(fileContent)))
	reader.Comma = rune(delimiter[0])
	reader.LazyQuotes = true
	reader.TrimLeadingSpace = true
	reader.FieldsPerRecord = -1

	// Read header
	headers, err := reader.Read()
	if err != nil {
		res.SetError(gerror.New(public.LangCtx(ctx, "Failed to read CSV headers")))
		return
	}

	// Build columns info
	columns := make([]*v1.CSVColumn, 0, len(headers))
	for i, header := range headers {
		columns = append(columns, &v1.CSVColumn{
			Index:      i,
			Name:       strings.TrimSpace(header),
			SampleData: "",
		})
	}

	// Read sample rows and count total
	sampleRows := make([][]string, 0, 5)
	totalRows := 0

	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			g.Log().Debugf(ctx, "Error reading CSV row: %v", err)
			continue
		}
		totalRows++

		if len(sampleRows) < 5 {
			sampleRows = append(sampleRows, record)

			// Fill sample data for columns
			if totalRows == 1 {
				for i, col := range columns {
					if i < len(record) {
						col.SampleData = strings.TrimSpace(record[i])
					}
				}
			}
		}
	}

	res.Data.Columns = columns
	res.Data.TotalRows = totalRows
	res.Data.SampleRows = sampleRows
	res.SetSuccess(public.LangCtx(ctx, "Preview generated successfully"))
	return
}
