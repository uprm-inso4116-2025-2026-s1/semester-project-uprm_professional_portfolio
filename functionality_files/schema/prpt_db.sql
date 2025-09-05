CREATE TABLE "users" (
  "id" uuid PRIMARY KEY NOT NULL,
  "email" text UNIQUE NOT NULL,
  "full_name" text NOT NULL,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE "companies" (
  "id" uuid PRIMARY KEY NOT NULL,
  "name" text UNIQUE NOT NULL,
  "website" text,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE "jobs" (
  "id" uuid PRIMARY KEY NOT NULL,
  "company_id" uuid NOT NULL,
  "title" text NOT NULL,
  "description" text,
  "location" text,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE "applications" (
  "id" uuid PRIMARY KEY NOT NULL,
  "user_id" uuid NOT NULL,
  "job_id" uuid NOT NULL,
  "status" text NOT NULL,
  "applied_at" timestamptz NOT NULL
);

CREATE INDEX "idx_jobs_company_id" ON "jobs" ("company_id");

CREATE UNIQUE INDEX "uq_applications_user_job" ON "applications" ("user_id", "job_id");

ALTER TABLE "jobs" ADD FOREIGN KEY ("company_id") REFERENCES "companies" ("id");

ALTER TABLE "applications" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "applications" ADD FOREIGN KEY ("job_id") REFERENCES "jobs" ("id");
