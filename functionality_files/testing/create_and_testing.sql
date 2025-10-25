-- ===========================
--  RESET (drop in dependency-safe order)
-- ===========================
DROP TABLE IF EXISTS "applications" CASCADE;
DROP TABLE IF EXISTS "jobs" CASCADE;
DROP TABLE IF EXISTS "companies" CASCADE;
DROP TABLE IF EXISTS "users" CASCADE;

-- ===========================
--  CREATE TABLES
-- ===========================
CREATE TABLE IF NOT EXISTS "users" (
  "id" uuid PRIMARY KEY NOT NULL,
  "email" text UNIQUE NOT NULL,
  "full_name" text NOT NULL,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS "companies" (
  "id" uuid PRIMARY KEY NOT NULL,
  "name" text UNIQUE NOT NULL,
  "website" text,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS "jobs" (
  "id" uuid PRIMARY KEY NOT NULL,
  "company_id" uuid NOT NULL,
  "title" text NOT NULL,
  "description" text,
  "location" text,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS "applications" (
  "id" uuid PRIMARY KEY NOT NULL,
  "user_id" uuid NOT NULL,
  "job_id" uuid NOT NULL,
  "status" text NOT NULL,
  "applied_at" timestamptz NOT NULL
);

-- ===========================
--  INDEXES
-- ===========================
CREATE INDEX IF NOT EXISTS "idx_jobs_company_id" ON "jobs" ("company_id");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_applications_user_job" ON "applications" ("user_id", "job_id");

-- ===========================
--  FOREIGN KEYS
-- ===========================
ALTER TABLE "jobs"
  ADD CONSTRAINT "jobs_company_id_fkey"
  FOREIGN KEY ("company_id") REFERENCES "companies" ("id");

ALTER TABLE "applications"
  ADD CONSTRAINT "applications_user_id_fkey"
  FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "applications"
  ADD CONSTRAINT "applications_job_id_fkey"
  FOREIGN KEY ("job_id") REFERENCES "jobs" ("id");

-- ======================================================
--  OPTIONAL: VERIFICATION QUERIES (keep commented)
-- ======================================================

-- -- Apps with user + job info
-- SELECT u.full_name, j.title, a.status, a.applied_at
-- FROM applications a
-- JOIN users u ON a.user_id = u.id
-- JOIN jobs  j ON a.job_id = j.id
-- ORDER BY a.applied_at DESC;

-- -- Jobs by company with application counts
-- SELECT c.name AS company, j.title, COUNT(a.id) AS applications
-- FROM jobs j
-- JOIN companies c ON j.company_id = c.id
-- LEFT JOIN applications a ON a.job_id = j.id
-- GROUP BY c.name, j.title
-- ORDER BY c.name, j.title;

-- -- Duplicate application should fail (tests UNIQUE (user_id, job_id))
-- INSERT INTO applications (id, user_id, job_id, status, applied_at)
-- VALUES (
--   gen_random_uuid(),
--   (SELECT id FROM users WHERE email='alice@example.com'),
--   (SELECT id FROM jobs  WHERE title='Software Engineer' LIMIT 1),
--   'pending',
--   now()
-- );

-- -- Sanity check of current applications
-- SELECT u.email, j.title, a.status, a.applied_at
-- FROM applications a
-- JOIN users u ON u.id = a.user_id
-- JOIN jobs  j ON j.id = a.job_id
-- ORDER BY a.applied_at DESC;