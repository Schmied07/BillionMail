package prospect

import (
	v1 "tetrisnewsemailing-core/api/prospect/v1"
	"tetrisnewsemailing-core/internal/consts"
	"tetrisnewsemailing-core/internal/service/prospect"
	"tetrisnewsemailing-core/internal/service/public"
	"bytes"
	"context"
	"encoding/base64"
	"encoding/csv"
	"fmt"
	"io"
	"strconv"
	"strings"

	"github.com/gogf/gf/v2/errors/gerror"
	"github.com/gogf/gf/v2/frame/g"
	"github.com/gogf/gf/v2/util/gvalid"
)

func (c *ControllerV1) ImportProspects(ctx context.Context, req *v1.ImportProspectsReq) (res *v1.ImportProspectsRes, err error) {
	res = &v1.ImportProspectsRes{}

	// Check if source exists
	source, err := prospect.GetSourceById(ctx, req.SourceId)
	if err != nil || source == nil {
		res.Code = 404
		res.SetError(gerror.New(public.LangCtx(ctx, "Source not found")))
		return
	}

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

	// Build header index map
	headerIndex := make(map[string]int)
	for i, header := range headers {
		headerIndex[strings.ToLower(strings.TrimSpace(header))] = i
	}

	// Build mapping
	fieldMapping := make(map[string]int)
	for _, m := range req.Mapping {
		if m.CsvColumn != "" && m.AppField != "" {
			lowerCol := strings.ToLower(strings.TrimSpace(m.CsvColumn))
			if idx, ok := headerIndex[lowerCol]; ok {
				fieldMapping[m.AppField] = idx
			}
		}
	}

	// Validate email field is mapped
	if _, ok := fieldMapping["email"]; !ok {
		res.SetError(gerror.New(public.LangCtx(ctx, "Email field mapping is required")))
		return
	}

	// Process rows
	var prospectsToImport []prospect.ProspectData
	importedCount := 0
	skippedCount := 0
	errorCount := 0

	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			g.Log().Debugf(ctx, "Error reading CSV row: %v", err)
			errorCount++
			continue
		}

		// Extract email (required)
		emailIdx := fieldMapping["email"]
		if emailIdx >= len(record) {
			errorCount++
			continue
		}
		email := strings.TrimSpace(record[emailIdx])
		if email == "" {
			errorCount++
			continue
		}

		// Validate email format
		if err := gvalid.New().Rules("email").Data(email).Run(ctx); err != nil {
			g.Log().Debugf(ctx, "Invalid email format: %s", email)
			errorCount++
			continue
		}

		// Check if email already exists
		exists, err := prospect.EmailExists(ctx, email, 0)
		if err != nil {
			errorCount++
			continue
		}
		if exists {
			skippedCount++
			continue
		}

		// Build prospect data
		pData := prospect.ProspectData{
			Email:    email,
			SourceId: req.SourceId,
			Status:   req.DefaultStatus,
			Score:    req.DefaultScore,
			Value:    source.DefaultValue,
		}

		// Map other fields
		if idx, ok := fieldMapping["company"]; ok && idx < len(record) {
			pData.Company = strings.TrimSpace(record[idx])
		}
		if idx, ok := fieldMapping["contact"]; ok && idx < len(record) {
			pData.Contact = strings.TrimSpace(record[idx])
		}
		if idx, ok := fieldMapping["phone"]; ok && idx < len(record) {
			pData.Phone = strings.TrimSpace(record[idx])
		}
		if idx, ok := fieldMapping["value"]; ok && idx < len(record) {
			if v, err := strconv.Atoi(strings.TrimSpace(record[idx])); err == nil && v > 0 {
				pData.Value = v
			}
		}
		if idx, ok := fieldMapping["score"]; ok && idx < len(record) {
			if s, err := strconv.Atoi(strings.TrimSpace(record[idx])); err == nil && s >= 1 && s <= 5 {
				pData.Score = s
			}
		}
		if idx, ok := fieldMapping["status"]; ok && idx < len(record) {
			status := strings.ToLower(strings.TrimSpace(record[idx]))
			if isValidStatus(status) {
				pData.Status = status
			}
		}
		if idx, ok := fieldMapping["tags"]; ok && idx < len(record) {
			tagsStr := strings.TrimSpace(record[idx])
			if tagsStr != "" {
				tags := strings.Split(tagsStr, ";")
				for i, tag := range tags {
					tags[i] = strings.TrimSpace(tag)
				}
				pData.Tags = tags
			}
		}
		if idx, ok := fieldMapping["notes"]; ok && idx < len(record) {
			pData.Notes = strings.TrimSpace(record[idx])
		}

		prospectsToImport = append(prospectsToImport, pData)
	}

	// Batch import
	if len(prospectsToImport) > 0 {
		count, err := prospect.BatchCreateProspects(ctx, prospectsToImport)
		if err != nil {
			res.SetError(gerror.New(public.LangCtx(ctx, "Failed to import prospects")))
			return res, nil
		}
		importedCount = count
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Prospects,
		Log:  fmt.Sprintf("Import prospects from CSV: %d imported, %d skipped, %d errors", importedCount, skippedCount, errorCount),
		Data: map[string]interface{}{
			"source_id":      req.SourceId,
			"imported_count": importedCount,
			"skipped_count":  skippedCount,
			"error_count":    errorCount,
		},
	})

	res.Data.ImportedCount = importedCount
	res.Data.SkippedCount = skippedCount
	res.Data.ErrorCount = errorCount
	res.SetSuccess(public.LangCtx(ctx, "Import completed: {} imported, {} skipped", importedCount, skippedCount))
	return
}

func isValidStatus(status string) bool {
	validStatuses := map[string]bool{
		"new":         true,
		"contacted":   true,
		"qualified":   true,
		"negotiation": true,
		"converted":   true,
	}
	return validStatuses[status]
}
