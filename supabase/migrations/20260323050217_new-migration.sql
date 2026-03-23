create extension if not exists pgcrypto;

-- =========================================================
-- 1. 회원
-- tb_users.id = auth.users.id 로 맞춤
-- =========================================================
create table if not exists public.tb_users (
  id uuid primary key references auth.users(id) on delete cascade,

  user_status_cd varchar(30) not null default 'ACTIVE',
  join_type_cd varchar(30) not null default 'KAKAO',
  service_use_yn char(1) not null default 'Y',
  last_login_dt timestamptz,

  profile_completed_yn char(1) not null default 'N',
  survey_completed_yn char(1) not null default 'N',
  photo_completed_yn char(1) not null default 'N',
  preview_completed_yn char(1) not null default 'N',

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_users_service_use_yn_chk check (service_use_yn in ('Y','N')),
  constraint tb_users_profile_completed_yn_chk check (profile_completed_yn in ('Y','N')),
  constraint tb_users_survey_completed_yn_chk check (survey_completed_yn in ('Y','N')),
  constraint tb_users_photo_completed_yn_chk check (photo_completed_yn in ('Y','N')),
  constraint tb_users_preview_completed_yn_chk check (preview_completed_yn in ('Y','N')),
  constraint tb_users_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 2. 회원 프로필
-- =========================================================
create table if not exists public.tb_user_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.tb_users(id) on delete cascade,

  nickname varchar(100) not null,
  gender_cd varchar(20),
  birth_year int,
  height_cm int,
  job_name varchar(100),
  education_level_cd varchar(30),
  region_cd varchar(30),
  intro_text text,
  smoking_yn char(1) default 'N',
  drinking_cd varchar(30),
  religion_cd varchar(30),
  marital_status_cd varchar(30),
  children_yn char(1) default 'N',
  profile_open_yn char(1) not null default 'Y',

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_user_profiles_user_id_uk unique (user_id),
  constraint tb_user_profiles_birth_year_chk check (birth_year is null or birth_year between 1900 and 2100),
  constraint tb_user_profiles_height_cm_chk check (height_cm is null or height_cm between 50 and 250),
  constraint tb_user_profiles_smoking_yn_chk check (smoking_yn in ('Y','N')),
  constraint tb_user_profiles_children_yn_chk check (children_yn in ('Y','N')),
  constraint tb_user_profiles_profile_open_yn_chk check (profile_open_yn in ('Y','N')),
  constraint tb_user_profiles_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 3. 약관 마스터
-- =========================================================
create table if not exists public.tb_terms (
  id uuid primary key default gen_random_uuid(),

  terms_type_cd varchar(30) not null,
  terms_title varchar(200) not null,
  terms_version varchar(30) not null,
  terms_content text not null,
  required_yn char(1) not null default 'Y',
  effective_start_dt timestamptz,
  effective_end_dt timestamptz,
  current_yn char(1) not null default 'Y',
  display_order int not null default 1,

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_terms_required_yn_chk check (required_yn in ('Y','N')),
  constraint tb_terms_current_yn_chk check (current_yn in ('Y','N')),
  constraint tb_terms_del_yn_chk check (del_yn in ('Y','N')),
  constraint tb_terms_type_version_uk unique (terms_type_cd, terms_version)
);

-- =========================================================
-- 4. 사용자 약관 동의 이력
-- =========================================================
create table if not exists public.tb_user_terms_agreements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.tb_users(id) on delete cascade,
  terms_id uuid not null references public.tb_terms(id) on delete restrict,

  agreed_yn char(1) not null,
  agreed_dt timestamptz,
  ip_address varchar(100),
  user_agent text,

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_user_terms_agreements_agreed_yn_chk check (agreed_yn in ('Y','N')),
  constraint tb_user_terms_agreements_del_yn_chk check (del_yn in ('Y','N')),
  constraint tb_user_terms_agreements_user_terms_uk unique (user_id, terms_id)
);

-- =========================================================
-- 5. 온보딩 단계
-- =========================================================
create table if not exists public.tb_onboarding_steps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.tb_users(id) on delete cascade,

  terms_agreed_yn char(1) not null default 'N',
  profile_completed_yn char(1) not null default 'N',
  survey_completed_yn char(1) not null default 'N',
  photo_completed_yn char(1) not null default 'N',
  preview_completed_yn char(1) not null default 'N',
  current_step_cd varchar(30) not null default 'TERMS',
  onboarding_completed_yn char(1) not null default 'N',
  completed_dt timestamptz,

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_onboarding_steps_user_id_uk unique (user_id),
  constraint tb_onboarding_steps_terms_agreed_yn_chk check (terms_agreed_yn in ('Y','N')),
  constraint tb_onboarding_steps_profile_completed_yn_chk check (profile_completed_yn in ('Y','N')),
  constraint tb_onboarding_steps_survey_completed_yn_chk check (survey_completed_yn in ('Y','N')),
  constraint tb_onboarding_steps_photo_completed_yn_chk check (photo_completed_yn in ('Y','N')),
  constraint tb_onboarding_steps_preview_completed_yn_chk check (preview_completed_yn in ('Y','N')),
  constraint tb_onboarding_steps_onboarding_completed_yn_chk check (onboarding_completed_yn in ('Y','N')),
  constraint tb_onboarding_steps_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 6. 설문 질문
-- =========================================================
create table if not exists public.tb_survey_questions (
  id uuid primary key default gen_random_uuid(),

  question_code varchar(50) not null,
  question_text text not null,
  question_type_cd varchar(30) not null,
  question_group_cd varchar(30) not null,
  admin_only_yn char(1) not null default 'N',
  required_yn char(1) not null default 'Y',
  active_yn char(1) not null default 'Y',
  display_order int not null default 1,

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_survey_questions_question_code_uk unique (question_code),
  constraint tb_survey_questions_admin_only_yn_chk check (admin_only_yn in ('Y','N')),
  constraint tb_survey_questions_required_yn_chk check (required_yn in ('Y','N')),
  constraint tb_survey_questions_active_yn_chk check (active_yn in ('Y','N')),
  constraint tb_survey_questions_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 7. 설문 선택지
-- =========================================================
create table if not exists public.tb_survey_question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.tb_survey_questions(id) on delete cascade,

  option_text varchar(300) not null,
  option_value varchar(100) not null,
  option_score numeric(10,2),
  display_order int not null default 1,
  active_yn char(1) not null default 'Y',

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_survey_question_options_active_yn_chk check (active_yn in ('Y','N')),
  constraint tb_survey_question_options_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 8. 사용자 설문 응답
-- =========================================================
create table if not exists public.tb_user_survey_answers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.tb_users(id) on delete cascade,
  question_id uuid not null references public.tb_survey_questions(id) on delete cascade,
  question_option_id uuid references public.tb_survey_question_options(id) on delete set null,

  answer_text text,
  answer_number numeric(10,2),
  answer_json jsonb,
  submitted_dt timestamptz,

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_user_survey_answers_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 9. 사용자 사진
-- =========================================================
create table if not exists public.tb_user_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.tb_users(id) on delete cascade,

  photo_type_cd varchar(30) not null,
  storage_path text not null,
  file_name varchar(255),
  mime_type varchar(100),
  file_size bigint,
  thumbnail_path text,
  main_photo_yn char(1) not null default 'N',
  sort_no int not null default 1,
  approval_status_cd varchar(30) not null default 'PENDING',
  visible_yn char(1) not null default 'Y',

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_user_photos_main_photo_yn_chk check (main_photo_yn in ('Y','N')),
  constraint tb_user_photos_visible_yn_chk check (visible_yn in ('Y','N')),
  constraint tb_user_photos_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 10. 좋아요
-- =========================================================
create table if not exists public.tb_likes (
  id uuid primary key default gen_random_uuid(),
  from_user_id uuid not null references public.tb_users(id) on delete cascade,
  to_user_id uuid not null references public.tb_users(id) on delete cascade,

  like_status_cd varchar(30) not null default 'SENT',
  opened_limit_dt timestamptz,
  mutual_like_yn char(1) not null default 'N',
  matched_yn char(1) not null default 'N',

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_likes_user_pair_chk check (from_user_id <> to_user_id),
  constraint tb_likes_mutual_like_yn_chk check (mutual_like_yn in ('Y','N')),
  constraint tb_likes_matched_yn_chk check (matched_yn in ('Y','N')),
  constraint tb_likes_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 11. 매칭
-- =========================================================
create table if not exists public.tb_matches (
  id uuid primary key default gen_random_uuid(),
  user_1_id uuid not null references public.tb_users(id) on delete cascade,
  user_2_id uuid not null references public.tb_users(id) on delete cascade,

  match_type_cd varchar(30) not null,
  match_status_cd varchar(30) not null default 'ACTIVE',
  matched_dt timestamptz not null default now(),
  ended_dt timestamptz,
  ended_reason_cd varchar(30),

  like_relation_id uuid references public.tb_likes(id) on delete set null,
  admin_recommend_user_id uuid references public.tb_users(id) on delete set null,

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_matches_user_pair_chk check (user_1_id <> user_2_id),
  constraint tb_matches_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 12. 매칭 후기
-- =========================================================
create table if not exists public.tb_match_reviews (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references public.tb_matches(id) on delete cascade,
  writer_user_id uuid not null references public.tb_users(id) on delete cascade,
  target_user_id uuid not null references public.tb_users(id) on delete cascade,

  rating_score numeric(2,1),
  review_text text,
  review_type_cd varchar(30),
  public_yn char(1) not null default 'N',
  reported_yn char(1) not null default 'N',

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_match_reviews_public_yn_chk check (public_yn in ('Y','N')),
  constraint tb_match_reviews_reported_yn_chk check (reported_yn in ('Y','N')),
  constraint tb_match_reviews_del_yn_chk check (del_yn in ('Y','N')),
  constraint tb_match_reviews_rating_chk check (rating_score is null or (rating_score >= 0 and rating_score <= 5)),
  constraint tb_match_reviews_match_writer_uk unique (match_id, writer_user_id)
);

-- =========================================================
-- 13. 알림
-- =========================================================
create table if not exists public.tb_alarm (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.tb_users(id) on delete cascade,

  alarm_type_cd varchar(30) not null,
  alarm_title varchar(200) not null,
  alarm_body text,
  read_yn char(1) not null default 'N',
  read_dt timestamptz,
  move_path varchar(500),
  related_table_name varchar(100),
  related_id uuid,

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_alarm_read_yn_chk check (read_yn in ('Y','N')),
  constraint tb_alarm_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 14. 알림 로그
-- =========================================================
create table if not exists public.tb_alarm_log (
  id uuid primary key default gen_random_uuid(),
  alarm_id uuid not null references public.tb_alarm(id) on delete cascade,

  send_channel_cd varchar(30) not null,
  send_status_cd varchar(30) not null,
  send_dt timestamptz,
  fail_code varchar(100),
  fail_message text,
  provider_message_id varchar(255),

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_alarm_log_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 15. 차단
-- =========================================================
create table if not exists public.tb_blocks (
  id uuid primary key default gen_random_uuid(),
  block_user_id uuid not null references public.tb_users(id) on delete cascade,
  blocked_user_id uuid not null references public.tb_users(id) on delete cascade,

  block_reason_cd varchar(30),
  block_reason_text text,
  active_yn char(1) not null default 'Y',

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_blocks_user_pair_chk check (block_user_id <> blocked_user_id),
  constraint tb_blocks_active_yn_chk check (active_yn in ('Y','N')),
  constraint tb_blocks_del_yn_chk check (del_yn in ('Y','N')),
  constraint tb_blocks_active_pair_uk unique (block_user_id, blocked_user_id)
);

-- =========================================================
-- 16. 신고
-- =========================================================
create table if not exists public.tb_reports (
  id uuid primary key default gen_random_uuid(),
  report_user_id uuid not null references public.tb_users(id) on delete cascade,
  target_user_id uuid not null references public.tb_users(id) on delete cascade,
  match_id uuid references public.tb_matches(id) on delete set null,

  report_type_cd varchar(30) not null,
  report_reason_cd varchar(30) not null,
  report_text text,
  process_status_cd varchar(30) not null default 'RECEIVED',
  processed_dt timestamptz,
  processed_user_id uuid references public.tb_users(id) on delete set null,

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_reports_user_pair_chk check (report_user_id <> target_user_id),
  constraint tb_reports_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 17. 로그인 로그
-- =========================================================
create table if not exists public.tb_login_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.tb_users(id) on delete set null,

  login_type_cd varchar(30),
  login_status_cd varchar(30),
  login_id_value varchar(255),
  provider_name varchar(50),
  ip_address varchar(100),
  user_agent text,
  device_info varchar(255),
  failure_code varchar(100),
  failure_message text,
  trace_id varchar(100),

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_login_logs_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 18. API 로그
-- =========================================================
create table if not exists public.tb_api_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.tb_users(id) on delete set null,

  trace_id varchar(100),
  request_method varchar(10),
  request_path varchar(500),
  request_query text,
  request_body jsonb,
  response_status_cd int,
  response_body jsonb,
  error_code varchar(100),
  error_message text,
  latency_ms int,
  client_ip varchar(100),
  user_agent text,
  function_name varchar(100),

  create_dt timestamptz not null default now(),
  create_user uuid references public.tb_users(id),
  update_dt timestamptz not null default now(),
  update_user uuid references public.tb_users(id),
  del_yn char(1) not null default 'N',

  constraint tb_api_logs_del_yn_chk check (del_yn in ('Y','N'))
);

-- =========================================================
-- 인덱스
-- =========================================================
create index if not exists idx_tb_user_profiles_user_id on public.tb_user_profiles(user_id);
create index if not exists idx_tb_user_terms_agreements_user_id on public.tb_user_terms_agreements(user_id);
create index if not exists idx_tb_user_terms_agreements_terms_id on public.tb_user_terms_agreements(terms_id);
create index if not exists idx_tb_onboarding_steps_user_id on public.tb_onboarding_steps(user_id);
create index if not exists idx_tb_survey_question_options_question_id on public.tb_survey_question_options(question_id);
create index if not exists idx_tb_user_survey_answers_user_id on public.tb_user_survey_answers(user_id);
create index if not exists idx_tb_user_survey_answers_question_id on public.tb_user_survey_answers(question_id);
create index if not exists idx_tb_user_photos_user_id on public.tb_user_photos(user_id);
create index if not exists idx_tb_likes_from_user_id on public.tb_likes(from_user_id);
create index if not exists idx_tb_likes_to_user_id on public.tb_likes(to_user_id);
create index if not exists idx_tb_matches_user_1_id on public.tb_matches(user_1_id);
create index if not exists idx_tb_matches_user_2_id on public.tb_matches(user_2_id);
create index if not exists idx_tb_match_reviews_match_id on public.tb_match_reviews(match_id);
create index if not exists idx_tb_alarm_user_id on public.tb_alarm(user_id);
create index if not exists idx_tb_alarm_log_alarm_id on public.tb_alarm_log(alarm_id);
create index if not exists idx_tb_blocks_block_user_id on public.tb_blocks(block_user_id);
create index if not exists idx_tb_blocks_blocked_user_id on public.tb_blocks(blocked_user_id);
create index if not exists idx_tb_reports_report_user_id on public.tb_reports(report_user_id);
create index if not exists idx_tb_reports_target_user_id on public.tb_reports(target_user_id);
create index if not exists idx_tb_login_logs_user_id on public.tb_login_logs(user_id);
create index if not exists idx_tb_login_logs_trace_id on public.tb_login_logs(trace_id);
create index if not exists idx_tb_api_logs_user_id on public.tb_api_logs(user_id);
create index if not exists idx_tb_api_logs_trace_id on public.tb_api_logs(trace_id);

-- =========================================================
-- RLS 활성화
-- =========================================================
alter table public.tb_users enable row level security;
alter table public.tb_user_profiles enable row level security;
alter table public.tb_terms enable row level security;
alter table public.tb_user_terms_agreements enable row level security;
alter table public.tb_onboarding_steps enable row level security;
alter table public.tb_survey_questions enable row level security;
alter table public.tb_survey_question_options enable row level security;
alter table public.tb_user_survey_answers enable row level security;
alter table public.tb_user_photos enable row level security;
alter table public.tb_likes enable row level security;
alter table public.tb_matches enable row level security;
alter table public.tb_match_reviews enable row level security;
alter table public.tb_alarm enable row level security;
alter table public.tb_alarm_log enable row level security;
alter table public.tb_blocks enable row level security;
alter table public.tb_reports enable row level security;
alter table public.tb_login_logs enable row level security;
alter table public.tb_api_logs enable row level security;

-- =========================================================
-- 최소 RLS 정책
-- =========================================================
drop policy if exists "tb_users_select_own" on public.tb_users;
create policy "tb_users_select_own"
on public.tb_users
for select
to authenticated
using (auth.uid() = id and del_yn = 'N');

drop policy if exists "tb_users_update_own" on public.tb_users;
create policy "tb_users_update_own"
on public.tb_users
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "tb_user_profiles_select_open" on public.tb_user_profiles;
create policy "tb_user_profiles_select_open"
on public.tb_user_profiles
for select
to authenticated
using (profile_open_yn = 'Y' and del_yn = 'N');

drop policy if exists "tb_user_profiles_insert_own" on public.tb_user_profiles;
create policy "tb_user_profiles_insert_own"
on public.tb_user_profiles
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "tb_user_profiles_update_own" on public.tb_user_profiles;
create policy "tb_user_profiles_update_own"
on public.tb_user_profiles
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "tb_terms_select_all" on public.tb_terms;
create policy "tb_terms_select_all"
on public.tb_terms
for select
to authenticated
using (current_yn = 'Y' and del_yn = 'N');

drop policy if exists "tb_survey_questions_select_all" on public.tb_survey_questions;
create policy "tb_survey_questions_select_all"
on public.tb_survey_questions
for select
to authenticated
using (active_yn = 'Y' and del_yn = 'N');

drop policy if exists "tb_survey_question_options_select_all" on public.tb_survey_question_options;
create policy "tb_survey_question_options_select_all"
on public.tb_survey_question_options
for select
to authenticated
using (active_yn = 'Y' and del_yn = 'N');

drop policy if exists "tb_user_terms_agreements_select_own" on public.tb_user_terms_agreements;
create policy "tb_user_terms_agreements_select_own"
on public.tb_user_terms_agreements
for select
to authenticated
using (auth.uid() = user_id and del_yn = 'N');

drop policy if exists "tb_user_terms_agreements_insert_own" on public.tb_user_terms_agreements;
create policy "tb_user_terms_agreements_insert_own"
on public.tb_user_terms_agreements
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "tb_onboarding_steps_select_own" on public.tb_onboarding_steps;
create policy "tb_onboarding_steps_select_own"
on public.tb_onboarding_steps
for select
to authenticated
using (auth.uid() = user_id and del_yn = 'N');

drop policy if exists "tb_onboarding_steps_insert_own" on public.tb_onboarding_steps;
create policy "tb_onboarding_steps_insert_own"
on public.tb_onboarding_steps
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "tb_onboarding_steps_update_own" on public.tb_onboarding_steps;
create policy "tb_onboarding_steps_update_own"
on public.tb_onboarding_steps
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "tb_user_survey_answers_select_own" on public.tb_user_survey_answers;
create policy "tb_user_survey_answers_select_own"
on public.tb_user_survey_answers
for select
to authenticated
using (auth.uid() = user_id and del_yn = 'N');

drop policy if exists "tb_user_survey_answers_insert_own" on public.tb_user_survey_answers;
create policy "tb_user_survey_answers_insert_own"
on public.tb_user_survey_answers
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "tb_user_survey_answers_update_own" on public.tb_user_survey_answers;
create policy "tb_user_survey_answers_update_own"
on public.tb_user_survey_answers
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "tb_user_photos_select_visible" on public.tb_user_photos;
create policy "tb_user_photos_select_visible"
on public.tb_user_photos
for select
to authenticated
using (visible_yn = 'Y' and del_yn = 'N');

drop policy if exists "tb_user_photos_insert_own" on public.tb_user_photos;
create policy "tb_user_photos_insert_own"
on public.tb_user_photos
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "tb_user_photos_update_own" on public.tb_user_photos;
create policy "tb_user_photos_update_own"
on public.tb_user_photos
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "tb_likes_select_related" on public.tb_likes;
create policy "tb_likes_select_related"
on public.tb_likes
for select
to authenticated
using ((auth.uid() = from_user_id or auth.uid() = to_user_id) and del_yn = 'N');

drop policy if exists "tb_likes_insert_sender" on public.tb_likes;
create policy "tb_likes_insert_sender"
on public.tb_likes
for insert
to authenticated
with check (auth.uid() = from_user_id);

drop policy if exists "tb_likes_update_sender" on public.tb_likes;
create policy "tb_likes_update_sender"
on public.tb_likes
for update
to authenticated
using (auth.uid() = from_user_id or auth.uid() = to_user_id)
with check (auth.uid() = from_user_id or auth.uid() = to_user_id);

drop policy if exists "tb_matches_select_related" on public.tb_matches;
create policy "tb_matches_select_related"
on public.tb_matches
for select
to authenticated
using ((auth.uid() = user_1_id or auth.uid() = user_2_id) and del_yn = 'N');

drop policy if exists "tb_match_reviews_select_related" on public.tb_match_reviews;
create policy "tb_match_reviews_select_related"
on public.tb_match_reviews
for select
to authenticated
using ((auth.uid() = writer_user_id or auth.uid() = target_user_id) and del_yn = 'N');

drop policy if exists "tb_match_reviews_insert_writer" on public.tb_match_reviews;
create policy "tb_match_reviews_insert_writer"
on public.tb_match_reviews
for insert
to authenticated
with check (auth.uid() = writer_user_id);

drop policy if exists "tb_alarm_select_own" on public.tb_alarm;
create policy "tb_alarm_select_own"
on public.tb_alarm
for select
to authenticated
using (auth.uid() = user_id and del_yn = 'N');

drop policy if exists "tb_alarm_update_own" on public.tb_alarm;
create policy "tb_alarm_update_own"
on public.tb_alarm
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "tb_blocks_select_own" on public.tb_blocks;
create policy "tb_blocks_select_own"
on public.tb_blocks
for select
to authenticated
using (auth.uid() = block_user_id and del_yn = 'N');

drop policy if exists "tb_blocks_insert_own" on public.tb_blocks;
create policy "tb_blocks_insert_own"
on public.tb_blocks
for insert
to authenticated
with check (auth.uid() = block_user_id);

drop policy if exists "tb_reports_select_own" on public.tb_reports;
create policy "tb_reports_select_own"
on public.tb_reports
for select
to authenticated
using (auth.uid() = report_user_id and del_yn = 'N');

drop policy if exists "tb_reports_insert_own" on public.tb_reports;
create policy "tb_reports_insert_own"
on public.tb_reports
for insert
to authenticated
with check (auth.uid() = report_user_id);