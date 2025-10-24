Context Map:
Legend:
U = Upstream (source of truth / provider)
D = Downstream (consumer)
(FK) = Integration via database foreign key (current state)
________________________________________
Profiles (Identity) — Upstream
•	Tables: users, student_profiles
•	Purpose: Source of truth for user identity (all roles) and student profile identity.
•	Invariants:
o	users.email is unique
o	student_profiles.user_id is unique (1:1 with a user)
Recruiting / Jobs — Downstream
•	Tables: companies, jobs, job_applications
•	Purpose: Companies post jobs; users apply to jobs.
•	Internal FK: jobs.company_id → companies.id (inside this context)
•	Invariants: One application per (user_id, job_id).
Programs & Mentoring — Downstream
•	Tables: programs, program_applications, mentor_assignments, matches (student↔mentor), feedback
•	Purpose: Non-recruiting flows: programs, mentor assignment/matching, feedback.
•	Note: matches here means student↔mentor, not recruiter↔candidate.
Audit / Logging — Sink
•	Tables: audit_logs
•	Purpose: Write-only audit trail of actions across the system.
________________________________________
Boundaries & Contracts
Profiles → Recruiting (U → D)
•	Current (FK): job_applications.user_id → users.id
•	Target (HTTP):
o	GET /profiles/users/:userId/snapshot (Profiles provides user identity)
o	GET /recruiting/jobs/:jobId/snapshot (Recruiting internal role snapshot)
Profiles → Programs & Mentoring (U → D)
•	Current (FKs):
o	program_applications.student_id → student_profiles.id
o	mentor_assignments.student_id → student_profiles.id
o	mentor_assignments.mentor_id → users.id
o	feedback.student_id → student_profiles.id
o	feedback.mentor_id → users.id
•	Target (HTTP):
o	GET /profiles/students/:studentId/snapshot
o	GET /profiles/users/:userId/snapshot
Profiles → Audit / Logging (U → D)
•	Current (FK): audit_logs.actor_id → users.id
•	Target (HTTP): POST /audit/records (write-only sink)
-	Profiles is the source of truth for identity. Downstream contexts should consume snapshots/events, not join across DBs.
