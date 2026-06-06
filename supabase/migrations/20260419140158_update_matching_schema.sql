create extension if not exists pgcrypto;

-- =========================================================
-- 2026-04-14 schema update
-- 1) profile / target / alarm setting
-- 2) log table FK 제거
-- 3) matching page 반영 보완
-- =========================================================

-- ---------------------------------------------------------
-- 1. 기본정보 수정 확장: tb_user_profile 컬럼 추가
-- ---------------------------------------------------------
alter table public.tb_user_profile
    add column if not exists region_detail_cd varchar(30),
    add column if not exists body_type_cd varchar(30),
    add column if not exists political_orientation_cd varchar(30),
    add column if not exists drink_type_cd varchar(30),
    add column if not exists diet_style_cd varchar(30),
    add column if not exists employment_type_cd varchar(30),
    add column if not exists job_detail_text text,
    add column if not exists asset_info_text text,

    -- MatchingPage 연락처 공개 대응
    add column if not exists contact_phone varchar(50),
    add column if not exists contact_kakao_id varchar(100),
    add column if not exists contact_open_yn char(1) not null default 'N';

comment on column public.tb_user_profile.region_detail_cd is '상세 지역 코드';
comment on column public.tb_user_profile.body_type_cd is '체형 코드';
comment on column public.tb_user_profile.political_orientation_cd is '정치 성향 코드';
comment on column public.tb_user_profile.drink_type_cd is '주종 코드';
comment on column public.tb_user_profile.diet_style_cd is '식습관 코드';
comment on column public.tb_user_profile.employment_type_cd is '직장인/사업자 등 고용 형태 코드';
comment on column public.tb_user_profile.job_detail_text is '직업 상세 설명';
comment on column public.tb_user_profile.asset_info_text is '자산 정보 텍스트';
comment on column public.tb_user_profile.contact_phone is '연락처 전화번호';
comment on column public.tb_user_profile.contact_kakao_id is '카카오톡 ID';
comment on column public.tb_user_profile.contact_open_yn is '연락처 공개 가능 여부';

alter table public.tb_user_profile
    drop constraint if exists ck_tb_user_profile_contact_open_yn;

alter table public.tb_user_profile
    add constraint ck_tb_user_profile_contact_open_yn
    check (contact_open_yn in ('Y','N'));

create index if not exists idx_tb_user_profile_region_cd
    on public.tb_user_profile(region_cd, region_detail_cd);

create index if not exists idx_tb_user_profile_match_base
    on public.tb_user_profile(gender_cd, birth_year, region_cd, region_detail_cd, height_cm);

-- ---------------------------------------------------------
-- 2. 매칭 기준 설정: tb_user_match_target 신규
-- ---------------------------------------------------------
create table if not exists public.tb_user_match_target (
    user_match_target_id                uuid primary key default gen_random_uuid(),
    user_id                             uuid not null unique references public.tb_user(user_id) on delete cascade,

    preferred_gender_cd                varchar(20),
    preferred_birth_year_from          integer,
    preferred_birth_year_to            integer,
    preferred_height_cm_from           integer,
    preferred_height_cm_to             integer,
    preferred_region_cd                varchar(30),
    preferred_region_detail_cd         varchar(30),
    preferred_education_level_cd       varchar(30),
    preferred_job_name                 varchar(100),
    preferred_body_type_cd             varchar(30),
    preferred_smoking_yn               char(1),
    preferred_drinking_cd              varchar(30),
    preferred_religion_cd              varchar(30),
    preferred_marital_status_cd        varchar(30),
    preferred_children_yn              char(1),
    preferred_political_orientation_cd varchar(30),
    preferred_conditions_text          text,
    extra_condition_json               jsonb not null default '{}'::jsonb,

    create_dt                          timestamptz not null default now(),
    create_user                        uuid,
    update_dt                          timestamptz not null default now(),
    update_user                        uuid,
    del_yn                             char(1) not null default 'N',

    constraint ck_tb_user_match_target_birth_year_range
        check (
            preferred_birth_year_from is null
            or preferred_birth_year_to is null
            or preferred_birth_year_from <= preferred_birth_year_to
        ),

    constraint ck_tb_user_match_target_height_range
        check (
            preferred_height_cm_from is null
            or preferred_height_cm_to is null
            or preferred_height_cm_from <= preferred_height_cm_to
        ),

    constraint ck_tb_user_match_target_birth_year_from
        check (
            preferred_birth_year_from is null
            or preferred_birth_year_from between 1900 and 2100
        ),

    constraint ck_tb_user_match_target_birth_year_to
        check (
            preferred_birth_year_to is null
            or preferred_birth_year_to between 1900 and 2100
        ),

    constraint ck_tb_user_match_target_height_from
        check (
            preferred_height_cm_from is null
            or preferred_height_cm_from between 80 and 250
        ),

    constraint ck_tb_user_match_target_height_to
        check (
            preferred_height_cm_to is null
            or preferred_height_cm_to between 80 and 250
        ),

    constraint ck_tb_user_match_target_preferred_smoking_yn
        check (preferred_smoking_yn in ('Y','N') or preferred_smoking_yn is null),

    constraint ck_tb_user_match_target_preferred_children_yn
        check (preferred_children_yn in ('Y','N') or preferred_children_yn is null),

    constraint ck_tb_user_match_target_del_yn
        check (del_yn in ('Y','N'))
);

comment on table public.tb_user_match_target is '사용자 매칭 기준 설정';
comment on column public.tb_user_match_target.user_id is '회원 ID';
comment on column public.tb_user_match_target.preferred_gender_cd is '선호 성별 코드';
comment on column public.tb_user_match_target.preferred_birth_year_from is '선호 출생연도 시작';
comment on column public.tb_user_match_target.preferred_birth_year_to is '선호 출생연도 끝';
comment on column public.tb_user_match_target.preferred_height_cm_from is '선호 키 시작(cm)';
comment on column public.tb_user_match_target.preferred_height_cm_to is '선호 키 끝(cm)';
comment on column public.tb_user_match_target.preferred_region_cd is '선호 지역 코드';
comment on column public.tb_user_match_target.preferred_region_detail_cd is '선호 상세 지역 코드';
comment on column public.tb_user_match_target.preferred_education_level_cd is '선호 학력 코드';
comment on column public.tb_user_match_target.preferred_job_name is '선호 직업명';
comment on column public.tb_user_match_target.preferred_body_type_cd is '선호 체형 코드';
comment on column public.tb_user_match_target.preferred_smoking_yn is '선호 흡연 여부';
comment on column public.tb_user_match_target.preferred_drinking_cd is '선호 음주 코드';
comment on column public.tb_user_match_target.preferred_religion_cd is '선호 종교 코드';
comment on column public.tb_user_match_target.preferred_marital_status_cd is '선호 혼인 상태 코드';
comment on column public.tb_user_match_target.preferred_children_yn is '선호 자녀 여부';
comment on column public.tb_user_match_target.preferred_political_orientation_cd is '선호 정치 성향 코드';
comment on column public.tb_user_match_target.preferred_conditions_text is '자유 입력 매칭 조건';
comment on column public.tb_user_match_target.extra_condition_json is 'Step6Target 추가 조건 JSON';

create index if not exists idx_tb_user_match_target_user_id
    on public.tb_user_match_target(user_id);

create index if not exists idx_tb_user_match_target_match_filter
    on public.tb_user_match_target(
        preferred_gender_cd,
        preferred_region_cd,
        preferred_region_detail_cd,
        preferred_birth_year_from,
        preferred_birth_year_to
    );

-- ---------------------------------------------------------
-- 3. 알림설정: tb_alarm_setting 신규
-- ---------------------------------------------------------
create table if not exists public.tb_alarm_setting (
    alarm_setting_id        uuid primary key default gen_random_uuid(),
    user_id                 uuid not null unique references public.tb_user(user_id) on delete cascade,
    matching_alarm_yn       char(1) not null default 'Y',
    chat_alarm_yn           char(1) not null default 'Y',
    notice_alarm_yn         char(1) not null default 'Y',
    create_dt               timestamptz not null default now(),
    create_user             uuid,
    update_dt               timestamptz not null default now(),
    update_user             uuid,
    del_yn                  char(1) not null default 'N',

    constraint ck_tb_alarm_setting_matching_alarm_yn
        check (matching_alarm_yn in ('Y','N')),
    constraint ck_tb_alarm_setting_chat_alarm_yn
        check (chat_alarm_yn in ('Y','N')),
    constraint ck_tb_alarm_setting_notice_alarm_yn
        check (notice_alarm_yn in ('Y','N')),
    constraint ck_tb_alarm_setting_del_yn
        check (del_yn in ('Y','N'))
);

comment on table public.tb_alarm_setting is '사용자 알림 설정';
comment on column public.tb_alarm_setting.user_id is '회원 ID';
comment on column public.tb_alarm_setting.matching_alarm_yn is '매칭 알림 수신 여부';
comment on column public.tb_alarm_setting.chat_alarm_yn is '채팅 알림 수신 여부';
comment on column public.tb_alarm_setting.notice_alarm_yn is '공지 알림 수신 여부';

create index if not exists idx_tb_alarm_setting_user_id
    on public.tb_alarm_setting(user_id);

-- ---------------------------------------------------------
-- 4. 고객센터 / 차단 화면용 조회 성능 인덱스 보강
-- ---------------------------------------------------------
create index if not exists idx_tb_inquiry_user_id_create_dt
    on public.tb_inquiry(user_id, create_dt desc);

create index if not exists idx_tb_inquiry_answer_inquiry_id
    on public.tb_inquiry_answer(inquiry_id);

create index if not exists idx_tb_block_blocker_user_id_active
    on public.tb_block(blocker_user_id, active_yn, del_yn);

-- ---------------------------------------------------------
-- 5. 로그 테이블 FK 제거
-- ---------------------------------------------------------
alter table public.tb_login_history
    drop constraint if exists tb_login_history_user_id_fkey;

alter table public.tb_audit_log
    drop constraint if exists tb_audit_log_actor_user_id_fkey;

alter table public.tb_data_access_log
    drop constraint if exists tb_data_access_log_user_id_fkey;

alter table public.tb_security_event
    drop constraint if exists tb_security_event_user_id_fkey;

alter table public.tb_api_log
    drop constraint if exists tb_api_log_user_id_fkey;

create index if not exists idx_tb_login_history_user_id_create_dt
    on public.tb_login_history(user_id, create_dt desc);

create index if not exists idx_tb_audit_log_actor_user_id_create_dt
    on public.tb_audit_log(actor_user_id, create_dt desc);

create index if not exists idx_tb_data_access_log_user_id_create_dt
    on public.tb_data_access_log(user_id, create_dt desc);

create index if not exists idx_tb_security_event_user_id_detected_dt
    on public.tb_security_event(user_id, detected_dt desc);

create index if not exists idx_tb_api_log_user_id_create_dt
    on public.tb_api_log(user_id, create_dt desc);

-- ---------------------------------------------------------
-- 6. MatchingPage pending review 판단 보완
--    review_completed_yn 단일 플래그만으로는 사용자별 판단이 어려움
-- ---------------------------------------------------------
alter table public.tb_match
    add column if not exists user_1_review_completed_yn char(1) not null default 'N',
    add column if not exists user_2_review_completed_yn char(1) not null default 'N';

comment on column public.tb_match.user_1_review_completed_yn is 'user_1 후기 작성 여부';
comment on column public.tb_match.user_2_review_completed_yn is 'user_2 후기 작성 여부';

alter table public.tb_match
    drop constraint if exists ck_tb_match_user_1_review_completed_yn;

alter table public.tb_match
    add constraint ck_tb_match_user_1_review_completed_yn
    check (user_1_review_completed_yn in ('Y','N'));

alter table public.tb_match
    drop constraint if exists ck_tb_match_user_2_review_completed_yn;

alter table public.tb_match
    add constraint ck_tb_match_user_2_review_completed_yn
    check (user_2_review_completed_yn in ('Y','N'));

create index if not exists idx_tb_match_user_1_review_pending
    on public.tb_match(user_1_id, user_1_review_completed_yn, match_status_cd, ended_dt);

create index if not exists idx_tb_match_user_2_review_pending
    on public.tb_match(user_2_id, user_2_review_completed_yn, match_status_cd, ended_dt);

-- 기존 review_completed_yn은 전체 완료 여부로 유지 가능
update public.tb_match
set review_completed_yn = case
    when user_1_review_completed_yn = 'Y' and user_2_review_completed_yn = 'Y' then 'Y'
    else 'N'
end
where true;

-- ---------------------------------------------------------
-- 7. MatchingPage 관련 인덱스 보강
-- ---------------------------------------------------------
create index if not exists idx_tb_like_sender_status_sent_dt
    on public.tb_like(sender_user_id, like_status_cd, sent_dt desc);

create index if not exists idx_tb_like_receiver_status_sent_dt
    on public.tb_like(receiver_user_id, like_status_cd, sent_dt desc);

create index if not exists idx_tb_match_user_1_status
    on public.tb_match(user_1_id, match_status_cd, matched_dt desc);

create index if not exists idx_tb_match_user_2_status
    on public.tb_match(user_2_id, match_status_cd, matched_dt desc);

create index if not exists idx_tb_chat_room_match_id
    on public.tb_chat_room(match_id);

create index if not exists idx_tb_contact_exchange_match_id
    on public.tb_contact_exchange(match_id);

-- ---------------------------------------------------------
-- 8. 기본값 데이터 적재
-- ---------------------------------------------------------
insert into public.tb_alarm_setting (
    user_id,
    matching_alarm_yn,
    chat_alarm_yn,
    notice_alarm_yn,
    create_user,
    update_user
)
select
    u.user_id,
    'Y',
    'Y',
    'Y',
    u.user_id,
    u.user_id
from public.tb_user u
left join public.tb_alarm_setting s
    on s.user_id = u.user_id
where s.user_id is null;

insert into public.tb_user_match_target (
    user_id,
    create_user,
    update_user
)
select
    u.user_id,
    u.user_id,
    u.user_id
from public.tb_user u
left join public.tb_user_match_target t
    on t.user_id = u.user_id
where t.user_id is null;