begin;

-- USERS
create table if not exists public.users (
  id uuid primary key,
  email text not null unique,
  full_name text,
  role text default 'student',  
  created_at timestamptz
);

-- COMPANIES
create table if not exists public.companies (
  id uuid primary key,
  name text not null unique,
  website text,
  created_at timestamptz
);

-- JOBS
create table if not exists public.jobs (
  id uuid primary key,
  company_id uuid not null,      
  title text not null,
  description text,
  location text,
  created_at timestamptz,
  constraint jobs_company_fk
    foreign key (company_id) references public.companies(id)
);
create index if not exists idx_jobs_company_id on public.jobs (company_id);

-- JOB APPLICATIONS
create table if not exists public.job_applications (
  id uuid primary key,
  user_id uuid not null,        
  job_id uuid not null,         
  status text,                   
  applied_at timestamptz,
  constraint job_applications_user_fk
    foreign key (user_id) references public.users(id),
  constraint job_applications_job_fk
    foreign key (job_id) references public.jobs(id)
);
create unique index if not exists uq_job_applications_user_job
  on public.job_applications (user_id, job_id);

-- PROGRAMS
create table if not exists public.programs (
  id uuid primary key,
  name text not null,
  code text,
  created_at timestamptz
);

-- STUDENT PROFILES
create table if not exists public.student_profiles (
  id uuid primary key,
  user_id uuid not null unique,  
  created_at timestamptz,
  constraint student_profiles_user_fk
    foreign key (user_id) references public.users(id) on delete cascade
    
);

-- PROGRAM APPLICATIONS
create table if not exists public.program_applications (
  id uuid primary key,
  student_id uuid not null,      
  program_id uuid not null,      
  status text,                   
  submitted_at timestamptz,
  constraint program_applications_student_fk
    foreign key (student_id) references public.student_profiles(id) on delete cascade,
  constraint program_applications_program_fk
    foreign key (program_id) references public.programs(id) on delete restrict
);
create unique index if not exists uq_program_applications_student_program
  on public.program_applications (student_id, program_id);

-- MENTOR ASSIGNMENTS
create table if not exists public.mentor_assignments (
  id uuid primary key,
  student_id uuid not null,      
  mentor_id uuid not null,       
  assigned_at timestamptz,
  constraint mentor_assignments_student_fk
    foreign key (student_id) references public.student_profiles(id) on delete cascade,
  constraint mentor_assignments_mentor_fk
    foreign key (mentor_id) references public.users(id) on delete restrict
);
create index if not exists idx_mentor_assignments_student
  on public.mentor_assignments (student_id);
create index if not exists idx_mentor_assignments_mentor
  on public.mentor_assignments (mentor_id);

-- MATCHES
create table if not exists public.matches (
  id uuid primary key,
  student_id uuid not null,
  mentor_id uuid not null,
  matched_at timestamptz,
  constraint matches_student_fk
    foreign key (student_id) references public.student_profiles(id) on delete cascade,
  constraint matches_mentor_fk
    foreign key (mentor_id) references public.users(id) on delete restrict
);
create index if not exists idx_matches_student
  on public.matches (student_id);
create index if not exists idx_matches_mentor
  on public.matches (mentor_id);

-- FEEDBACK
create table if not exists public.feedback (
  id uuid primary key,
  student_id uuid not null,
  mentor_id uuid,                
  notes text,
  submitted_at timestamptz,
  constraint feedback_student_fk
    foreign key (student_id) references public.student_profiles(id) on delete cascade,
  constraint feedback_mentor_fk
    foreign key (mentor_id) references public.users(id) on delete set null
);
create index if not exists idx_feedback_student
  on public.feedback (student_id);
create index if not exists idx_feedback_mentor
  on public.feedback (mentor_id);

-- AUDIT LOGS:
create table if not exists public.audit_logs (
  id uuid primary key,
  action text not null,          
  actor_id uuid,                 
  entity_type text not null,     
  entity_id uuid not null,       
  created_at timestamptz
);
alter table public.audit_logs
  drop constraint if exists audit_logs_actor_fk;
alter table public.audit_logs
  add constraint audit_logs_actor_fk
  foreign key (actor_id) references public.users(id) on delete set null
;

commit;
