-- 셀프 소개 게시글
create table if not exists public.tb_self_introduce (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.tb_user(user_id) on delete cascade,
    title varchar(30) not null,
    content text not null,
    view_count integer not null default 0,
    is_deleted boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

comment on table public.tb_self_introduce is '셀프 소개 게시글';
comment on column public.tb_self_introduce.user_id is '작성자';
comment on column public.tb_self_introduce.title is '제목';
comment on column public.tb_self_introduce.content is '내용';
comment on column public.tb_self_introduce.view_count is '조회수';

-- 관심(댓글)
create table if not exists public.tb_self_introduce_comment (
    id uuid primary key default gen_random_uuid(),
    self_introduce_id uuid not null references public.tb_self_introduce(id) on delete cascade,
    parent_comment_id uuid references public.tb_self_introduce_comment(id) on delete cascade,
    user_id uuid not null references public.tb_user(user_id) on delete cascade,
    content varchar(300) not null,
    is_deleted boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

comment on table public.tb_self_introduce_comment is '셀프 소개 관심';
comment on column public.tb_self_introduce_comment.self_introduce_id is '셀프 소개 ID';
comment on column public.tb_self_introduce_comment.parent_comment_id is '상위 관심 ID';
comment on column public.tb_self_introduce_comment.user_id is '작성자';
comment on column public.tb_self_introduce_comment.content is '관심 내용';

create index if not exists idx_tb_self_introduce_user_id
    on public.tb_self_introduce(user_id);

create index if not exists idx_tb_self_introduce_created_at
    on public.tb_self_introduce(created_at desc)
    where is_deleted = false;

create index if not exists idx_tb_self_introduce_comment_intro_id
    on public.tb_self_introduce_comment(self_introduce_id, created_at)
    where is_deleted = false;
