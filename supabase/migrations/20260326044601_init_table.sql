create extension if not exists pgcrypto;

-- =========================================================
-- 공통 코드
-- =========================================================
create table public.tb_code_group (
    code_group_id      uuid primary key default gen_random_uuid(),
    code_group_key     varchar(100) not null unique,
    code_group_name    varchar(200) not null,
    use_yn             char(1) not null default 'Y',
    create_dt          timestamptz not null default now(),
    create_user        uuid,
    update_dt          timestamptz not null default now(),
    update_user        uuid,
    del_yn             char(1) not null default 'N',
    constraint ck_tb_code_group_use_yn check (use_yn in ('Y','N')),
    constraint ck_tb_code_group_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_code_group is '공통 코드 그룹';
comment on column public.tb_code_group.code_group_key is '코드 그룹 식별자';
comment on column public.tb_code_group.code_group_name is '코드 그룹명';

create table public.tb_code (
    code_id            uuid primary key default gen_random_uuid(),
    code_group_id      uuid not null references public.tb_code_group(code_group_id),
    code_key           varchar(100) not null,
    code_name          varchar(200) not null,
    code_value         varchar(200),
    sort_no            integer not null default 1,
    use_yn             char(1) not null default 'Y',
    create_dt          timestamptz not null default now(),
    create_user        uuid,
    update_dt          timestamptz not null default now(),
    update_user        uuid,
    del_yn             char(1) not null default 'N',
    constraint uq_tb_code unique (code_group_id, code_key),
    constraint ck_tb_code_use_yn check (use_yn in ('Y','N')),
    constraint ck_tb_code_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_code is '공통 상세 코드';
comment on column public.tb_code.code_key is '상세 코드 키';
comment on column public.tb_code.code_value is '시스템 내부 값';

-- =========================================================
-- 사용자 / 인증 / 권한
-- =========================================================
create table public.tb_user (
    user_id                    uuid primary key,
    user_status_cd             varchar(30) not null,
    join_type_cd               varchar(30) not null,
    profile_completed_yn       char(1) not null default 'N',
    survey_completed_yn        char(1) not null default 'N',
    photo_completed_yn         char(1) not null default 'N',
    preview_completed_yn       char(1) not null default 'N',
    matching_locked_yn         char(1) not null default 'N',
    last_login_dt              timestamptz,
    create_dt                  timestamptz not null default now(),
    create_user                uuid,
    update_dt                  timestamptz not null default now(),
    update_user                uuid,
    del_yn                     char(1) not null default 'N',
    constraint ck_tb_user_profile_completed_yn check (profile_completed_yn in ('Y','N')),
    constraint ck_tb_user_survey_completed_yn check (survey_completed_yn in ('Y','N')),
    constraint ck_tb_user_photo_completed_yn check (photo_completed_yn in ('Y','N')),
    constraint ck_tb_user_preview_completed_yn check (preview_completed_yn in ('Y','N')),
    constraint ck_tb_user_matching_locked_yn check (matching_locked_yn in ('Y','N')),
    constraint ck_tb_user_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_user is '회원 기본 테이블';
comment on column public.tb_user.user_id is '사용자 ID(auth.users.id와 동일하게 사용 권장)';
comment on column public.tb_user.matching_locked_yn is '평가 전 다음 매칭 잠금 여부';

create table public.tb_user_auth (
    user_auth_id               uuid primary key default gen_random_uuid(),
    user_id                    uuid not null unique references public.tb_user(user_id) on delete cascade,
    login_id                   varchar(255),
    provider_cd                varchar(30) not null,
    provider_user_key          varchar(255),
    password_hash              text,
    email_verified_yn          char(1) not null default 'N',
    login_fail_count           integer not null default 0,
    account_locked_yn          char(1) not null default 'N',
    account_locked_dt          timestamptz,
    last_password_change_dt    timestamptz,
    create_dt                  timestamptz not null default now(),
    create_user                uuid,
    update_dt                  timestamptz not null default now(),
    update_user                uuid,
    del_yn                     char(1) not null default 'N',
    constraint uq_tb_user_auth_login_id unique (login_id),
    constraint uq_tb_user_auth_provider unique (provider_cd, provider_user_key),
    constraint ck_tb_user_auth_email_verified_yn check (email_verified_yn in ('Y','N')),
    constraint ck_tb_user_auth_account_locked_yn check (account_locked_yn in ('Y','N')),
    constraint ck_tb_user_auth_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_user_auth is '사용자 인증 정보';
comment on column public.tb_user_auth.provider_cd is '로그인 제공자 코드(KAKAO, GOOGLE 등)';
comment on column public.tb_user_auth.provider_user_key is '외부 인증 제공자 사용자 식별값';

create table public.tb_role (
    role_id            uuid primary key default gen_random_uuid(),
    role_key           varchar(50) not null unique,
    role_name          varchar(100) not null,
    use_yn             char(1) not null default 'Y',
    create_dt          timestamptz not null default now(),
    create_user        uuid,
    update_dt          timestamptz not null default now(),
    update_user        uuid,
    del_yn             char(1) not null default 'N',
    constraint ck_tb_role_use_yn check (use_yn in ('Y','N')),
    constraint ck_tb_role_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_role is '역할 마스터';

create table public.tb_user_role (
    user_role_id       uuid primary key default gen_random_uuid(),
    user_id            uuid not null references public.tb_user(user_id) on delete cascade,
    role_id            uuid not null references public.tb_role(role_id),
    create_dt          timestamptz not null default now(),
    create_user        uuid,
    update_dt          timestamptz not null default now(),
    update_user        uuid,
    del_yn             char(1) not null default 'N',
    constraint uq_tb_user_role unique (user_id, role_id),
    constraint ck_tb_user_role_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_user_role is '사용자-역할 매핑';

-- =========================================================
-- 약관 / 프로필 / 사진 / 설문
-- =========================================================
create table public.tb_terms (
    terms_id              uuid primary key default gen_random_uuid(),
    terms_type_cd         varchar(30) not null,
    terms_version         varchar(30) not null,
    terms_title           varchar(200) not null,
    terms_content         text not null,
    required_yn           char(1) not null default 'Y',
    current_yn            char(1) not null default 'Y',
    effective_start_dt    timestamptz,
    effective_end_dt      timestamptz,
    create_dt             timestamptz not null default now(),
    create_user           uuid,
    update_dt             timestamptz not null default now(),
    update_user           uuid,
    del_yn                char(1) not null default 'N',
    constraint uq_tb_terms unique (terms_type_cd, terms_version),
    constraint ck_tb_terms_required_yn check (required_yn in ('Y','N')),
    constraint ck_tb_terms_current_yn check (current_yn in ('Y','N')),
    constraint ck_tb_terms_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_terms is '약관 마스터';

create table public.tb_user_terms_agreement (
    user_terms_agreement_id   uuid primary key default gen_random_uuid(),
    user_id                   uuid not null references public.tb_user(user_id) on delete cascade,
    terms_id                  uuid not null references public.tb_terms(terms_id),
    agreed_yn                 char(1) not null,
    agreed_dt                 timestamptz,
    ip_address                inet,
    user_agent                text,
    create_dt                 timestamptz not null default now(),
    create_user               uuid,
    update_dt                 timestamptz not null default now(),
    update_user               uuid,
    del_yn                    char(1) not null default 'N',
    constraint uq_tb_user_terms_agreement unique (user_id, terms_id),
    constraint ck_tb_user_terms_agreement_agreed_yn check (agreed_yn in ('Y','N')),
    constraint ck_tb_user_terms_agreement_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_user_terms_agreement is '사용자 약관 동의 이력';

create table public.tb_user_profile (
    user_profile_id        uuid primary key default gen_random_uuid(),
    user_id                uuid not null unique references public.tb_user(user_id) on delete cascade,
    nickname               varchar(100) not null,
    gender_cd              varchar(20) not null,
    birth_year             integer,
    height_cm              integer,
    job_name               varchar(100),
    education_level_cd     varchar(30),
    region_cd              varchar(30),
    intro_text             text,
    smoking_yn             char(1) not null default 'N',
    drinking_cd            varchar(30),
    religion_cd            varchar(30),
    marital_status_cd      varchar(30),
    children_yn            char(1) not null default 'N',
    profile_open_yn        char(1) not null default 'Y',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_user_profile_birth_year check (birth_year is null or birth_year between 1900 and 2100),
    constraint ck_tb_user_profile_height_cm check (height_cm is null or height_cm between 80 and 250),
    constraint ck_tb_user_profile_smoking_yn check (smoking_yn in ('Y','N')),
    constraint ck_tb_user_profile_children_yn check (children_yn in ('Y','N')),
    constraint ck_tb_user_profile_profile_open_yn check (profile_open_yn in ('Y','N')),
    constraint ck_tb_user_profile_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_user_profile is '회원 프로필';
comment on column public.tb_user_profile.profile_open_yn is '프로필 노출 여부';

create table public.tb_profile_photo (
    profile_photo_id       uuid primary key default gen_random_uuid(),
    user_id                uuid not null references public.tb_user(user_id) on delete cascade,
    photo_type_cd          varchar(30) not null,
    storage_path           text not null,
    thumbnail_path         text,
    mime_type              varchar(100),
    file_size              bigint,
    sort_no                integer not null default 1,
    main_photo_yn          char(1) not null default 'N',
    approval_status_cd     varchar(30) not null default 'PENDING',
    visible_yn             char(1) not null default 'Y',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_profile_photo_main_photo_yn check (main_photo_yn in ('Y','N')),
    constraint ck_tb_profile_photo_visible_yn check (visible_yn in ('Y','N')),
    constraint ck_tb_profile_photo_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_profile_photo is '회원 프로필 사진';
comment on column public.tb_profile_photo.photo_type_cd is '사진 유형(FACE, FULL_BODY 등)';
comment on column public.tb_profile_photo.approval_status_cd is '사진 승인 상태';

create table public.tb_survey_question (
    survey_question_id     uuid primary key default gen_random_uuid(),
    question_code          varchar(50) not null unique,
    question_group_cd      varchar(30) not null,
    question_type_cd       varchar(30) not null,
    question_text          text not null,
    admin_only_yn          char(1) not null default 'N',
    required_yn            char(1) not null default 'Y',
    display_order          integer not null default 1,
    active_yn              char(1) not null default 'Y',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_survey_question_admin_only_yn check (admin_only_yn in ('Y','N')),
    constraint ck_tb_survey_question_required_yn check (required_yn in ('Y','N')),
    constraint ck_tb_survey_question_active_yn check (active_yn in ('Y','N')),
    constraint ck_tb_survey_question_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_survey_question is '설문 질문';
comment on column public.tb_survey_question.admin_only_yn is '관리자만 열람 가능한 질문 여부';

create table public.tb_survey_option (
    survey_option_id       uuid primary key default gen_random_uuid(),
    survey_question_id     uuid not null references public.tb_survey_question(survey_question_id) on delete cascade,
    option_text            varchar(300) not null,
    option_value           varchar(100) not null,
    option_score           numeric(10,2),
    display_order          integer not null default 1,
    active_yn              char(1) not null default 'Y',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint uq_tb_survey_option unique (survey_question_id, option_value),
    constraint ck_tb_survey_option_active_yn check (active_yn in ('Y','N')),
    constraint ck_tb_survey_option_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_survey_option is '설문 선택지';

create table public.tb_user_survey_answer (
    user_survey_answer_id  uuid primary key default gen_random_uuid(),
    user_id                uuid not null references public.tb_user(user_id) on delete cascade,
    survey_question_id     uuid not null references public.tb_survey_question(survey_question_id) on delete cascade,
    survey_option_id       uuid references public.tb_survey_option(survey_option_id),
    answer_text            text,
    answer_number          numeric(10,2),
    answer_json            jsonb,
    submitted_dt           timestamptz not null default now(),
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint uq_tb_user_survey_answer unique (user_id, survey_question_id),
    constraint ck_tb_user_survey_answer_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_user_survey_answer is '사용자 설문 응답';

-- =========================================================
-- 보석 / 결제
-- =========================================================
create table public.tb_user_balance (
    user_balance_id        uuid primary key default gen_random_uuid(),
    user_id                uuid not null unique references public.tb_user(user_id) on delete cascade,
    balance_amount         integer not null default 0,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_user_balance_amount check (balance_amount >= 0),
    constraint ck_tb_user_balance_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_user_balance is '사용자 보석 현재 잔액';

create table public.tb_product (
    product_id             uuid primary key default gen_random_uuid(),
    product_type_cd        varchar(30) not null,
    product_name           varchar(200) not null,
    gem_amount             integer not null,
    sale_price             numeric(12,2) not null,
    currency_cd            varchar(10) not null default 'KRW',
    active_yn              char(1) not null default 'Y',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_product_gem_amount check (gem_amount > 0),
    constraint ck_tb_product_sale_price check (sale_price >= 0),
    constraint ck_tb_product_active_yn check (active_yn in ('Y','N')),
    constraint ck_tb_product_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_product is '결제 상품';
comment on column public.tb_product.gem_amount is '상품 구매 시 지급 보석 수량';

create table public.tb_payment (
    payment_id             uuid primary key default gen_random_uuid(),
    user_id                uuid not null references public.tb_user(user_id),
    product_id             uuid not null references public.tb_product(product_id),
    payment_status_cd      varchar(30) not null,
    store_provider_cd      varchar(30) not null,
    external_order_id      varchar(255),
    external_receipt_id    varchar(255),
    paid_amount            numeric(12,2) not null,
    paid_dt                timestamptz,
    cancel_dt              timestamptz,
    raw_payload            jsonb,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint uq_tb_payment_external_receipt unique (store_provider_cd, external_receipt_id),
    constraint ck_tb_payment_paid_amount check (paid_amount >= 0),
    constraint ck_tb_payment_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_payment is '결제 이력';

create table public.tb_user_balance_txn (
    user_balance_txn_id    uuid primary key default gen_random_uuid(),
    user_id                uuid not null references public.tb_user(user_id),
    txn_type_cd            varchar(30) not null,
    txn_reason_cd          varchar(30) not null,
    amount                 integer not null,
    balance_after_amount   integer not null,
    payment_id             uuid references public.tb_payment(payment_id),
    like_id                uuid,
    match_id               uuid,
    ref_table_name         varchar(100),
    ref_id                 uuid,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_user_balance_txn_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_user_balance_txn is '보석 원장';
comment on column public.tb_user_balance_txn.amount is '증가 시 양수, 차감 시 음수';
comment on column public.tb_user_balance_txn.balance_after_amount is '거래 반영 후 잔액';

-- =========================================================
-- 호감 / 매칭 / 채팅 / 평가
-- =========================================================
create table public.tb_like (
    like_id                uuid primary key default gen_random_uuid(),
    sender_user_id         uuid not null references public.tb_user(user_id) on delete cascade,
    receiver_user_id       uuid not null references public.tb_user(user_id) on delete cascade,
    like_status_cd         varchar(30) not null,
    sent_dt                timestamptz not null default now(),
    expire_dt              timestamptz not null,
    responded_dt           timestamptz,
    refunded_yn            char(1) not null default 'N',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_like_user_pair check (sender_user_id <> receiver_user_id),
    constraint ck_tb_like_refunded_yn check (refunded_yn in ('Y','N')),
    constraint ck_tb_like_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_like is '호감 요청 이력';
comment on column public.tb_like.expire_dt is '호감 응답 만료 일시(7일 정책)';

create table public.tb_match (
    match_id               uuid primary key default gen_random_uuid(),
    like_id                uuid unique references public.tb_like(like_id),
    user_1_id              uuid not null references public.tb_user(user_id) on delete cascade,
    user_2_id              uuid not null references public.tb_user(user_id) on delete cascade,
    match_type_cd          varchar(30) not null,
    match_status_cd        varchar(30) not null,
    matched_dt             timestamptz not null default now(),
    chat_end_dt            timestamptz,
    review_completed_yn    char(1) not null default 'N',
    ended_dt               timestamptz,
    ended_reason_cd        varchar(30),
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_match_user_pair check (user_1_id <> user_2_id),
    constraint ck_tb_match_review_completed_yn check (review_completed_yn in ('Y','N')),
    constraint ck_tb_match_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_match is '매칭 성사 관계';
comment on column public.tb_match.match_status_cd is '매칭 상태(ACTIVE, LOCKED_FOR_REVIEW, ENDED 등)';

create table public.tb_chat_room (
    chat_room_id           uuid primary key default gen_random_uuid(),
    match_id               uuid not null unique references public.tb_match(match_id) on delete cascade,
    room_status_cd         varchar(30) not null default 'ACTIVE',
    opened_dt              timestamptz not null default now(),
    closed_dt              timestamptz,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_chat_room_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_chat_room is '채팅방';

create table public.tb_chat_message (
    chat_message_id        uuid primary key default gen_random_uuid(),
    chat_room_id           uuid not null references public.tb_chat_room(chat_room_id) on delete cascade,
    sender_user_id         uuid not null references public.tb_user(user_id) on delete cascade,
    message_type_cd        varchar(30) not null default 'TEXT',
    message_text           text,
    sent_dt                timestamptz not null default now(),
    deleted_yn             char(1) not null default 'N',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_chat_message_deleted_yn check (deleted_yn in ('Y','N')),
    constraint ck_tb_chat_message_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_chat_message is '채팅 메시지';

create table public.tb_contact_exchange (
    contact_exchange_id    uuid primary key default gen_random_uuid(),
    match_id               uuid not null unique references public.tb_match(match_id) on delete cascade,
    user_1_agree_yn        char(1) not null default 'N',
    user_1_agree_dt        timestamptz,
    user_2_agree_yn        char(1) not null default 'N',
    user_2_agree_dt        timestamptz,
    exposed_yn             char(1) not null default 'N',
    exposed_dt             timestamptz,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_contact_exchange_user_1_agree_yn check (user_1_agree_yn in ('Y','N')),
    constraint ck_tb_contact_exchange_user_2_agree_yn check (user_2_agree_yn in ('Y','N')),
    constraint ck_tb_contact_exchange_exposed_yn check (exposed_yn in ('Y','N')),
    constraint ck_tb_contact_exchange_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_contact_exchange is '연락처 공개 상호 동의 정보';

create table public.tb_match_review (
    match_review_id        uuid primary key default gen_random_uuid(),
    match_id               uuid not null references public.tb_match(match_id) on delete cascade,
    writer_user_id         uuid not null references public.tb_user(user_id) on delete cascade,
    target_user_id         uuid not null references public.tb_user(user_id) on delete cascade,
    met_yn                 char(1),
    contact_exchanged_yn   char(1),
    manner_score           numeric(2,1),
    review_text            text,
    report_yn              char(1) not null default 'N',
    submitted_dt           timestamptz not null default now(),
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint uq_tb_match_review unique (match_id, writer_user_id),
    constraint ck_tb_match_review_met_yn check (met_yn in ('Y','N') or met_yn is null),
    constraint ck_tb_match_review_contact_exchanged_yn check (contact_exchanged_yn in ('Y','N') or contact_exchanged_yn is null),
    constraint ck_tb_match_review_report_yn check (report_yn in ('Y','N')),
    constraint ck_tb_match_review_manner_score check (manner_score is null or (manner_score >= 0 and manner_score <= 5)),
    constraint ck_tb_match_review_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_match_review is '매칭 종료 후 평가';

create table public.tb_block (
    block_id               uuid primary key default gen_random_uuid(),
    blocker_user_id        uuid not null references public.tb_user(user_id) on delete cascade,
    blocked_user_id        uuid not null references public.tb_user(user_id) on delete cascade,
    block_reason_cd        varchar(30),
    active_yn              char(1) not null default 'Y',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint uq_tb_block unique (blocker_user_id, blocked_user_id),
    constraint ck_tb_block_user_pair check (blocker_user_id <> blocked_user_id),
    constraint ck_tb_block_active_yn check (active_yn in ('Y','N')),
    constraint ck_tb_block_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_block is '사용자 차단';

create table public.tb_report (
    report_id              uuid primary key default gen_random_uuid(),
    reporter_user_id       uuid not null references public.tb_user(user_id) on delete cascade,
    target_user_id         uuid not null references public.tb_user(user_id) on delete cascade,
    match_id               uuid references public.tb_match(match_id),
    report_type_cd         varchar(30) not null,
    report_reason_cd       varchar(30) not null,
    report_text            text,
    process_status_cd      varchar(30) not null default 'RECEIVED',
    processed_user_id      uuid references public.tb_user(user_id),
    processed_dt           timestamptz,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_report_user_pair check (reporter_user_id <> target_user_id),
    constraint ck_tb_report_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_report is '신고 이력';

-- =========================================================
-- 알림 / 컨텐츠 / 문의
-- =========================================================
create table public.tb_alarm (
    alarm_id               uuid primary key default gen_random_uuid(),
    user_id                uuid not null references public.tb_user(user_id) on delete cascade,
    alarm_type_cd          varchar(30) not null,
    alarm_title            varchar(200) not null,
    alarm_body             text,
    read_yn                char(1) not null default 'N',
    read_dt                timestamptz,
    move_path              varchar(500),
    related_table_name     varchar(100),
    related_id             uuid,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_alarm_read_yn check (read_yn in ('Y','N')),
    constraint ck_tb_alarm_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_alarm is '사용자 알림';

create table public.tb_alarm_log (
    alarm_log_id           uuid primary key default gen_random_uuid(),
    alarm_id               uuid not null references public.tb_alarm(alarm_id) on delete cascade,
    send_channel_cd        varchar(30) not null,
    send_status_cd         varchar(30) not null,
    send_dt                timestamptz,
    fail_code              varchar(100),
    fail_message           text,
    provider_message_id    varchar(255),
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_alarm_log_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_alarm_log is '알림 발송 로그';

create table public.tb_content (
    content_id             uuid primary key default gen_random_uuid(),
    content_type_cd        varchar(30) not null,
    title                  varchar(300) not null,
    body                   text not null,
    publish_yn             char(1) not null default 'N',
    publish_dt             timestamptz,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_content_publish_yn check (publish_yn in ('Y','N')),
    constraint ck_tb_content_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_content is '운영 컨텐츠';

create table public.tb_inquiry (
    inquiry_id             uuid primary key default gen_random_uuid(),
    user_id                uuid not null references public.tb_user(user_id) on delete cascade,
    inquiry_type_cd        varchar(30) not null,
    title                  varchar(300) not null,
    content                text not null,
    inquiry_status_cd      varchar(30) not null default 'RECEIVED',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_inquiry_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_inquiry is '1:1 문의';

create table public.tb_inquiry_answer (
    inquiry_answer_id      uuid primary key default gen_random_uuid(),
    inquiry_id             uuid not null unique references public.tb_inquiry(inquiry_id) on delete cascade,
    answer_user_id         uuid references public.tb_user(user_id),
    answer_content         text not null,
    answered_dt            timestamptz not null default now(),
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_inquiry_answer_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_inquiry_answer is '문의 답변';

-- =========================================================
-- 보안 / 감사 / 운영
-- =========================================================
create table public.tb_login_history (
    login_history_id       uuid primary key default gen_random_uuid(),
    user_id                uuid references public.tb_user(user_id),
    login_type_cd          varchar(30),
    login_status_cd        varchar(30) not null,
    provider_cd            varchar(30),
    ip_address             inet,
    user_agent             text,
    device_info            varchar(255),
    failure_code           varchar(100),
    failure_message        text,
    trace_id               varchar(100),
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_login_history_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_login_history is '로그인 성공/실패 이력';

create table public.tb_audit_log (
    audit_log_id           uuid primary key default gen_random_uuid(),
    actor_user_id          uuid references public.tb_user(user_id),
    action_cd              varchar(30) not null,
    target_table_name      varchar(100) not null,
    target_id              uuid,
    before_data            jsonb,
    after_data             jsonb,
    reason_text            text,
    trace_id               varchar(100),
    ip_address             inet,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_audit_log_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_audit_log is '주요 데이터 변경 감사 로그';

create table public.tb_data_access_log (
    data_access_log_id     uuid primary key default gen_random_uuid(),
    user_id                uuid references public.tb_user(user_id),
    target_table_name      varchar(100) not null,
    target_id              uuid,
    access_type_cd         varchar(30) not null,
    access_reason_text     text,
    trace_id               varchar(100),
    ip_address             inet,
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_data_access_log_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_data_access_log is '조회/다운로드 등 열람 로그';

create table public.tb_security_event (
    security_event_id      uuid primary key default gen_random_uuid(),
    user_id                uuid references public.tb_user(user_id),
    event_type_cd          varchar(30) not null,
    event_grade_cd         varchar(30),
    event_message          text,
    ip_address             inet,
    trace_id               varchar(100),
    detected_dt            timestamptz not null default now(),
    processed_yn           char(1) not null default 'N',
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_security_event_processed_yn check (processed_yn in ('Y','N')),
    constraint ck_tb_security_event_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_security_event is '보안 이상 이벤트';

create table public.tb_api_log (
    api_log_id             uuid primary key default gen_random_uuid(),
    user_id                uuid references public.tb_user(user_id),
    trace_id               varchar(100),
    request_method         varchar(10),
    request_path           varchar(500),
    request_query          text,
    request_body           jsonb,
    response_status_cd     integer,
    response_body          jsonb,
    error_code             varchar(100),
    error_message          text,
    latency_ms             integer,
    client_ip              inet,
    user_agent             text,
    function_name          varchar(100),
    create_dt              timestamptz not null default now(),
    create_user            uuid,
    update_dt              timestamptz not null default now(),
    update_user            uuid,
    del_yn                 char(1) not null default 'N',
    constraint ck_tb_api_log_del_yn check (del_yn in ('Y','N'))
);

comment on table public.tb_api_log is 'API 요청/응답 운영 로그';