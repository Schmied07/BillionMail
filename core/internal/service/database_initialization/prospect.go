package database_initialization

import (
	"context"
	"github.com/gogf/gf/v2/frame/g"
)

func init() {
	registerHandler(func() {
		prospectSQLList := []string{
			// Prospect sources table
			`CREATE TABLE IF NOT EXISTS bm_prospect_sources (
				id SERIAL PRIMARY KEY,
				name VARCHAR(100) NOT NULL,
				default_value INTEGER NOT NULL DEFAULT 0,
				description TEXT DEFAULT '',
				color VARCHAR(20) DEFAULT '#3b82f6',
				create_time INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW()),
				update_time INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW()),
				UNIQUE(name)
			)`,

			// Prospects table
			`CREATE TABLE IF NOT EXISTS bm_prospects (
				id SERIAL PRIMARY KEY,
				company VARCHAR(255) DEFAULT '',
				contact VARCHAR(255) DEFAULT '',
				email VARCHAR(320) NOT NULL,
				phone VARCHAR(50) DEFAULT '',
				value INTEGER NOT NULL DEFAULT 0,
				score INTEGER NOT NULL DEFAULT 3,
				status VARCHAR(20) NOT NULL DEFAULT 'new',
				tags JSONB DEFAULT '[]'::jsonb,
				notes TEXT DEFAULT '',
				source_id INTEGER,
				last_contact INTEGER DEFAULT 0,
				attribs JSONB DEFAULT '{}'::jsonb,
				industry VARCHAR(100) DEFAULT '',
				company_size VARCHAR(20) DEFAULT '',
				website VARCHAR(255) DEFAULT '',
				address TEXT DEFAULT '',
				siret VARCHAR(14) DEFAULT '',
				revenue INTEGER DEFAULT 0,
				create_time INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW()),
				update_time INTEGER NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW()),
				FOREIGN KEY (source_id) REFERENCES bm_prospect_sources(id) ON DELETE SET NULL,
				UNIQUE(email)
			)`,

			// Indexes
			`CREATE INDEX IF NOT EXISTS idx_bm_prospects_email ON bm_prospects(email)`,
			`CREATE INDEX IF NOT EXISTS idx_bm_prospects_status ON bm_prospects(status)`,
			`CREATE INDEX IF NOT EXISTS idx_bm_prospects_source_id ON bm_prospects(source_id)`,
			`CREATE INDEX IF NOT EXISTS idx_bm_prospects_create_time ON bm_prospects(create_time)`,
			`CREATE INDEX IF NOT EXISTS idx_bm_prospects_value ON bm_prospects(value)`,
		}

		for _, sql := range prospectSQLList {
			_, err := g.DB().Exec(context.Background(), sql)
			if err != nil {
				g.Log().Error(context.Background(), "Failed to execute prospect SQL:", err, sql)
				return
			}
		}

		// Add columns if not exists (for migrations)
		_ = AddColumnIfNotExists("bm_prospects", "attribs", "JSONB", "'{}'::jsonb", false)
		_ = AddColumnIfNotExists("bm_prospects", "last_contact", "INTEGER", "0", true)

		g.Log().Info(context.Background(), "Prospect tables initialized successfully")
	})
}
