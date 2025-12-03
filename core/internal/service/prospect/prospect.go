package prospect

import (
        v1 "tetrisnewsemailing-core/api/prospect/v1"
        "context"
        "encoding/json"
        "strings"
        "time"

        "github.com/gogf/gf/v2/frame/g"
)

// ========== Source Functions ==========

func GetSourcesWithPage(ctx context.Context, page, pageSize int, keyword string) ([]*v1.ProspectSource, int, error) {
        model := g.DB().Model("bm_prospect_sources").Ctx(ctx)

        if keyword != "" {
                model = model.WhereLike("name", "%"+keyword+"%").
                        WhereOrLike("description", "%"+keyword+"%")
        }

        total, err := model.Count()
        if err != nil {
                return nil, 0, err
        }

        var sources []*v1.ProspectSource
        err = model.Page(page, pageSize).
                OrderDesc("create_time").
                Scan(&sources)

        return sources, total, err
}

func GetAllSources(ctx context.Context) ([]*v1.ProspectSource, error) {
        var sources []*v1.ProspectSource
        err := g.DB().Model("bm_prospect_sources").
                Ctx(ctx).
                OrderDesc("create_time").
                Scan(&sources)
        return sources, err
}

func GetSourceById(ctx context.Context, id int) (*v1.ProspectSource, error) {
        var source v1.ProspectSource
        err := g.DB().Model("bm_prospect_sources").Ctx(ctx).Where("id", id).Scan(&source)
        if err != nil {
                return nil, err
        }
        if source.Id == 0 {
                return nil, nil
        }
        return &source, nil
}

func SourceNameExists(ctx context.Context, name string, excludeId int) (bool, error) {
        model := g.DB().Model("bm_prospect_sources").Ctx(ctx).Where("name", name)
        if excludeId > 0 {
                model = model.WhereNot("id", excludeId)
        }
        count, err := model.Count()
        return count > 0, err
}

func CreateSource(ctx context.Context, name string, defaultValue int, description, color string) (int, error) {
        now := time.Now().Unix()
        data := g.Map{
                "name":          name,
                "default_value": defaultValue,
                "description":   description,
                "color":         color,
                "create_time":   int(now),
                "update_time":   int(now),
        }
        lastInsertId, err := g.DB().Model("bm_prospect_sources").Ctx(ctx).Data(data).InsertAndGetId()
        return int(lastInsertId), err
}

func UpdateSource(ctx context.Context, id int, data g.Map) error {
        data["update_time"] = time.Now().Unix()
        _, err := g.DB().Model("bm_prospect_sources").Ctx(ctx).Data(data).Where("id", id).Update()
        return err
}

func DeleteSource(ctx context.Context, id int) error {
        _, err := g.DB().Model("bm_prospect_sources").Ctx(ctx).Where("id", id).Delete()
        return err
}

// ========== Prospect Functions ==========

type ProspectListParams struct {
        Page      int
        PageSize  int
        Keyword   string
        Status    string
        SourceId  int
        SortBy    string
        SortOrder string
}

type ProspectData struct {
        Company     string
        Contact     string
        Email       string
        Phone       string
        Value       int
        Score       int
        Status      string
        Tags        []string
        Notes       string
        SourceId    int
        // Company Information fields
        Industry    string
        CompanySize string
        Website     string
        Address     string
        Siret       string
        Revenue     int
}

type ProspectStats struct {
        TotalCount      int
        TotalValue      int
        AverageScore    float64
        ConversionRate  float64
        StatusBreakdown map[string]int
        SourceBreakdown map[string]int
}

func GetProspectsWithPage(ctx context.Context, params ProspectListParams) ([]*v1.Prospect, int, error) {
        // Build base query for counting (without Fields)
        countModel := g.DB().Model("bm_prospects p").Ctx(ctx)

        if params.Keyword != "" {
                keyword := "%" + params.Keyword + "%"
                countModel = countModel.Where("(p.company LIKE ? OR p.contact LIKE ? OR p.email LIKE ?)", keyword, keyword, keyword)
        }

        if params.Status != "" {
                countModel = countModel.Where("p.status", params.Status)
        }

        if params.SourceId > 0 {
                countModel = countModel.Where("p.source_id", params.SourceId)
        }

        total, err := countModel.Count()
        if err != nil {
                return nil, 0, err
        }

        // Build query for data with JOIN and Fields
        model := g.DB().Model("bm_prospects p").
                LeftJoin("bm_prospect_sources s", "p.source_id = s.id").
                Fields("p.*, s.name as source_name").
                Ctx(ctx)

        if params.Keyword != "" {
                keyword := "%" + params.Keyword + "%"
                model = model.Where("(p.company LIKE ? OR p.contact LIKE ? OR p.email LIKE ?)", keyword, keyword, keyword)
        }

        if params.Status != "" {
                model = model.Where("p.status", params.Status)
        }

        if params.SourceId > 0 {
                model = model.Where("p.source_id", params.SourceId)
        }

        // Sort
        sortBy := params.SortBy
        if sortBy == "" {
                sortBy = "create_time"
        }
        sortOrder := params.SortOrder
        if sortOrder == "" {
                sortOrder = "desc"
        }

        if sortOrder == "desc" {
                model = model.OrderDesc("p." + sortBy)
        } else {
                model = model.OrderAsc("p." + sortBy)
        }

        var prospects []*v1.Prospect
        err = model.Page(params.Page, params.PageSize).Scan(&prospects)
        if err != nil {
                return nil, 0, err
        }

        // Parse tags JSON
        for _, p := range prospects {
                if p.Tags == nil {
                        p.Tags = []string{}
                }
        }

        return prospects, total, nil
}

func GetProspectById(ctx context.Context, id int) (*v1.Prospect, error) {
        var prospect v1.Prospect
        err := g.DB().Model("bm_prospects p").
                LeftJoin("bm_prospect_sources s", "p.source_id = s.id").
                Fields("p.*, s.name as source_name").
                Ctx(ctx).
                Where("p.id", id).
                Scan(&prospect)
        if err != nil {
                return nil, err
        }
        if prospect.Id == 0 {
                return nil, nil
        }
        if prospect.Tags == nil {
                prospect.Tags = []string{}
        }
        return &prospect, nil
}

func EmailExists(ctx context.Context, email string, excludeId int) (bool, error) {
        model := g.DB().Model("bm_prospects").Ctx(ctx).Where("email", strings.ToLower(email))
        if excludeId > 0 {
                model = model.WhereNot("id", excludeId)
        }
        count, err := model.Count()
        return count > 0, err
}

func CreateProspect(ctx context.Context, data ProspectData) (int, error) {
        now := time.Now().Unix()

        tagsJson, _ := json.Marshal(data.Tags)

        insertData := g.Map{
                "company":      data.Company,
                "contact":      data.Contact,
                "email":        strings.ToLower(data.Email),
                "phone":        data.Phone,
                "value":        data.Value,
                "score":        data.Score,
                "status":       data.Status,
                "tags":         string(tagsJson),
                "notes":        data.Notes,
                "source_id":    data.SourceId,
                "industry":     data.Industry,
                "company_size": data.CompanySize,
                "website":      data.Website,
                "address":      data.Address,
                "siret":        data.Siret,
                "revenue":      data.Revenue,
                "create_time":  int(now),
                "update_time":  int(now),
        }

        lastInsertId, err := g.DB().Model("bm_prospects").Ctx(ctx).Data(insertData).InsertAndGetId()
        return int(lastInsertId), err
}

func UpdateProspect(ctx context.Context, id int, data g.Map) error {
        data["update_time"] = time.Now().Unix()

        // Convert tags to JSON if present
        if tags, ok := data["tags"]; ok {
                if tagsSlice, ok := tags.([]string); ok {
                        tagsJson, _ := json.Marshal(tagsSlice)
                        data["tags"] = string(tagsJson)
                }
        }

        _, err := g.DB().Model("bm_prospects").Ctx(ctx).Data(data).Where("id", id).Update()
        return err
}

func DeleteProspects(ctx context.Context, ids []int) (int, error) {
        result, err := g.DB().Model("bm_prospects").Ctx(ctx).WhereIn("id", ids).Delete()
        if err != nil {
                return 0, err
        }
        affected, _ := result.RowsAffected()
        return int(affected), nil
}

func CountProspectsBySource(ctx context.Context, sourceId int) (int, error) {
        return g.DB().Model("bm_prospects").Ctx(ctx).Where("source_id", sourceId).Count()
}

func BatchCreateProspects(ctx context.Context, prospects []ProspectData) (int, error) {
        if len(prospects) == 0 {
                return 0, nil
        }

        const batchSize = 1000
        totalBatches := (len(prospects) + batchSize - 1) / batchSize
        totalAffected := 0
        now := time.Now().Unix()

        for i := 0; i < totalBatches; i++ {
                startIdx := i * batchSize
                endIdx := (i + 1) * batchSize
                if endIdx > len(prospects) {
                        endIdx = len(prospects)
                }

                currentBatch := prospects[startIdx:endIdx]

                var data []g.Map
                for _, p := range currentBatch {
                        tagsJson, _ := json.Marshal(p.Tags)
                        data = append(data, g.Map{
                                "company":      p.Company,
                                "contact":      p.Contact,
                                "email":        strings.ToLower(p.Email),
                                "phone":        p.Phone,
                                "value":        p.Value,
                                "score":        p.Score,
                                "status":       p.Status,
                                "tags":         string(tagsJson),
                                "notes":        p.Notes,
                                "source_id":    p.SourceId,
                                "industry":     p.Industry,
                                "company_size": p.CompanySize,
                                "website":      p.Website,
                                "address":      p.Address,
                                "siret":        p.Siret,
                                "revenue":      p.Revenue,
                                "create_time":  int(now),
                                "update_time":  int(now),
                        })
                }

                result, err := g.DB().Model("bm_prospects").Ctx(ctx).Data(data).InsertIgnore()
                if err != nil {
                        g.Log().Error(ctx, "Failed to insert batch %d/%d: %v", i+1, totalBatches, err)
                        return totalAffected, err
                }

                affected, _ := result.RowsAffected()
                totalAffected += int(affected)
        }

        return totalAffected, nil
}

func GetProspectStats(ctx context.Context) (*ProspectStats, error) {
        stats := &ProspectStats{
                StatusBreakdown: make(map[string]int),
                SourceBreakdown: make(map[string]int),
        }

        // Total count and value
        var result struct {
                Count int     `json:"count"`
                Value int     `json:"value"`
                Score float64 `json:"score"`
        }

        err := g.DB().Model("bm_prospects").
                Ctx(ctx).
                Fields("COUNT(*) as count, COALESCE(SUM(value), 0) as value, COALESCE(AVG(score), 0) as score").
                Scan(&result)
        if err != nil {
                return nil, err
        }

        stats.TotalCount = result.Count
        stats.TotalValue = result.Value
        stats.AverageScore = result.Score

        // Conversion rate
        if stats.TotalCount > 0 {
                var convertedCount int
                convertedCount, err = g.DB().Model("bm_prospects").Ctx(ctx).Where("status", "converted").Count()
                if err == nil {
                        stats.ConversionRate = float64(convertedCount) / float64(stats.TotalCount) * 100
                }
        }

        // Status breakdown
        var statusCounts []struct {
                Status string `json:"status"`
                Count  int    `json:"count"`
        }
        err = g.DB().Model("bm_prospects").
                Ctx(ctx).
                Fields("status, COUNT(*) as count").
                Group("status").
                Scan(&statusCounts)
        if err == nil {
                for _, sc := range statusCounts {
                        stats.StatusBreakdown[sc.Status] = sc.Count
                }
        }

        // Source breakdown
        var sourceCounts []struct {
                SourceName string `json:"source_name"`
                Count      int    `json:"count"`
        }
        err = g.DB().Model("bm_prospects p").
                LeftJoin("bm_prospect_sources s", "p.source_id = s.id").
                Ctx(ctx).
                Fields("COALESCE(s.name, 'Unknown') as source_name, COUNT(*) as count").
                Group("s.name").
                Scan(&sourceCounts)
        if err == nil {
                for _, sc := range sourceCounts {
                        stats.SourceBreakdown[sc.SourceName] = sc.Count
                }
        }

        return stats, nil
}


// ========== Reminder Functions ==========

type ReminderListParams struct {
        Page       int
        PageSize   int
        ProspectId int
        Completed  *bool
        Type       string
}

type ReminderData struct {
        Title      string
        ProspectId int
        Type       string
        DueDate    int64
        Notes      string
}

type ReminderUpdateData struct {
        Title     string
        Type      string
        DueDate   int64
        Notes     string
        Completed *bool
}

func GetReminderList(ctx context.Context, params ReminderListParams) (int, []*v1.Reminder, error) {
        model := g.DB().Model("bm_prospect_reminders r").
                LeftJoin("bm_prospects p", "r.prospect_id = p.id").
                Ctx(ctx).
                Fields("r.*, p.company as prospect_name")

        // Apply filters
        if params.ProspectId > 0 {
                model = model.Where("r.prospect_id", params.ProspectId)
        }

        if params.Completed != nil {
                model = model.Where("r.completed", *params.Completed)
        }

        if params.Type != "" {
                model = model.Where("r.type", params.Type)
        }

        // Get total count
        total, err := model.Count()
        if err != nil {
                return 0, nil, err
        }

        // Get paginated results
        var reminders []*v1.Reminder
        err = model.Page(params.Page, params.PageSize).
                OrderDesc("r.due_date").
                Scan(&reminders)

        return total, reminders, err
}

func GetReminderById(ctx context.Context, id int) (*v1.Reminder, error) {
        var reminder v1.Reminder
        err := g.DB().Model("bm_prospect_reminders r").
                LeftJoin("bm_prospects p", "r.prospect_id = p.id").
                Ctx(ctx).
                Fields("r.*, p.company as prospect_name").
                Where("r.id", id).
                Scan(&reminder)

        if err != nil {
                return nil, err
        }
        if reminder.Id == 0 {
                return nil, nil
        }
        return &reminder, nil
}

func ReminderExists(ctx context.Context, id int) (bool, error) {
        count, err := g.DB().Model("bm_prospect_reminders").Ctx(ctx).Where("id", id).Count()
        return count > 0, err
}

func ProspectExists(ctx context.Context, id int) (bool, error) {
        count, err := g.DB().Model("bm_prospects").Ctx(ctx).Where("id", id).Count()
        return count > 0, err
}

func CreateReminder(ctx context.Context, data ReminderData) (int, error) {
        now := time.Now().Unix()

        insertData := g.Map{
                "title":       data.Title,
                "prospect_id": data.ProspectId,
                "type":        data.Type,
                "due_date":    data.DueDate,
                "notes":       data.Notes,
                "completed":   false,
                "create_time": int(now),
                "update_time": int(now),
        }

        lastInsertId, err := g.DB().Model("bm_prospect_reminders").Ctx(ctx).Data(insertData).InsertAndGetId()
        return int(lastInsertId), err
}

func UpdateReminder(ctx context.Context, id int, data ReminderUpdateData) error {
        updateData := g.Map{
                "update_time": time.Now().Unix(),
        }

        if data.Title != "" {
                updateData["title"] = data.Title
        }
        if data.Type != "" {
                updateData["type"] = data.Type
        }
        if data.DueDate > 0 {
                updateData["due_date"] = data.DueDate
        }
        if data.Notes != "" {
                updateData["notes"] = data.Notes
        }
        if data.Completed != nil {
                updateData["completed"] = *data.Completed
        }

        _, err := g.DB().Model("bm_prospect_reminders").Ctx(ctx).Data(updateData).Where("id", id).Update()
        return err
}

func DeleteReminders(ctx context.Context, ids []int) error {
        _, err := g.DB().Model("bm_prospect_reminders").Ctx(ctx).WhereIn("id", ids).Delete()
        return err
}
