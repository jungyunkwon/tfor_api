api 서버 개발 가이드
[1] tfor/backapi 프로젝트 폴더 구조(권장 표준)

tfor/backapi/
├── supabase/
│   ├── config.toml
│   ├── migrations/
│   │   └── YYYYMMDDHHMMSS_init.sql
│   ├── seed.sql
│   └── functions/
│       ├── _shared/
│       │   ├── cors.ts                 # corsHeaders 단일 정의
│       │   ├── response.ts             # ok(), fail() 응답 헬퍼
│       │   ├── auth.ts                 # getUserOrThrow(), getJwtOrThrow()
│       │   ├── validate.ts             # zod 등 검증(선택)
│       │   ├── errors.ts               # ErrorCode enum + AppError
│       │   └── types.ts                # 공통 타입
│       ├── profiles/
│       │   └── index.ts                # 프로필/설문/사진 업로드 관련 API
│       ├── matching/
│       │   └── index.ts                # 추천, 스킵(정책), 현재 매칭 상태
│       ├── likes/
│       │   └── index.ts                # 호감 보내기/받기/수락/거절/만료/환불
│       ├── chats/
│       │   └── index.ts                # 채팅방, 연락처 공개 동의/조회
│       ├── evaluations/
│       │   └── index.ts                # 평가 제출, 매칭 종료, 보석 2개 지급
│       ├── contents/
│       │   └── index.ts                # 컨텐츠 리스트/상세(관리자 포함은 별도)
│       ├── inquiries/
│       │   └── index.ts                # 문의 작성/내역/답변 상태
│       ├── payments/
│       │   └── index.ts                # 결제 검증/지급(플랫폼 연동용)
│       └── admin/
│           └── index.ts                # 관리자(유저/신고/컨텐츠)
└── README.md

[2] backapi 명명 규칙(전역)

1) 폴더/파일
- Edge Function 폴더명: kebab-case 또는 단일 도메인명 (예: likes, profile-setup)  ※ 위 표준은 단수 도메인명
- 엔트리 파일: index.ts 고정
- 공통 폴더: _shared/ 고정(선택이 아니라 “표준”)

2) 코드 네이밍
- 함수/변수: camelCase
- 타입/인터페이스/클래스: PascalCase
- 상수: SCREAMING_SNAKE_CASE
- URL path: kebab-case
- boolean: is/has/can prefix (isMatched, hasProfile)

3) Error / Enum
- ErrorCode enum: PascalCase + 값은 SCREAMING_SNAKE_CASE
  예) enum ErrorCode { UNAUTHORIZED, FORBIDDEN, VALIDATION_FAILED, ... }
- 에러 이름(코드): E_<DOMAIN>_<DETAIL>
  예) E_LIKES_ALREADY_SENT, E_PROFILE_NOT_COMPLETE

4) DB 네이밍
- table: snake_case, 복수 (user_profiles, like_requests)
- column: snake_case (created_at, profile_completed_at)
- enum(디비): snake_case (like_status)
- FK: <target>_id (user_id, match_id)

5) API 응답 규칙
- 성공: { "data": ... } 또는 { "data": null }
- 실패: { "error": { "code": "...", "message": "...", "details": ... } }
- 목록: { "data": { "items": [], "page": {...} } }

[3] Edge Function 개발 패턴(= restful-tasks 스타일 고정)

A. 모든 함수는 아래 5가지를 반드시 포함
1) OPTIONS 프리플라이트 처리
2) CORS 헤더 일괄 적용
3) createClient(SUPABASE_URL, SUPABASE_ANON_KEY, { global.headers.Authorization = req.Authorization })
   - “호출 유저의 Auth 컨텍스트”로 DB 접근 (RLS 적용)
4) URLPattern으로 라우팅 + method switch
5) try/catch에서 표준 에러 응답

(restful-tasks가 이 패턴을 그대로 보여줌) :contentReference[oaicite:1]{index=1}

B. 라우팅 규칙
- 각 함수는 “도메인 단위”로 분리
- 함수 내부는 다음 URL prefix를 가짐
  profiles:   /profiles/*
  likes:      /likes/*
  matching:   /matching/*
  chats:      /chats/*
  evaluations:/evaluations/*
  contents:   /contents/*
  inquiries:  /inquiries/*
  payments:   /payments/*
  admin:      /admin/*

C. 서비스-DB 규칙
- 일반 유저 요청 처리: anon key + 유저 Authorization (RLS 필수)
- service_role 사용: 배치/관리자/결제 검증 등 “내부 전용”에서만 제한적으로

[4] 개발 가이드 프롬프트(복붙용)

너는 tfor 프로젝트의 코딩 에이전트다. 아래 규칙을 절대 위반하지 마라.

[ANTI_GRAVITY_GLOBAL_RULE]
- 작업 시작 전 Global Rule을 먼저 읽고 따른다.
- tfor/FUNCTIONAL_SPEC.md를 먼저 읽는다.
- tfor/FlowChart.md 수정이 필요하면 “사용자 confirm 이후”에만 한다.
- 각 페이지 폴더 상단 code_guide.md를 먼저 읽고 기능/테스트/사용법을 메모리에 반영한 뒤 구현한다.
- Workspace 밖 파일 수정 금지, 명시되지 않은 파일 생성 금지, 불필요한 구조 변경 금지
- 추측 구현 금지, 요구사항 애매하면 구현 금지, 기존 개발 패턴/설계 임의 변경 금지

[backapi(Edge Functions) 표준]
- 모든 API는 Supabase Edge Function(Deno)로 구현한다.
- 예시(restful-tasks/index.ts) 라우팅 패턴을 그대로 따른다:
  - OPTIONS 처리 + corsHeaders 적용
  - createClient에 req.Authorization을 전달하여 RLS가 적용되게 한다
  - URLPattern + method switch 로 라우팅한다
  - 표준 성공/실패 응답 포맷을 유지한다
- 함수 폴더는 supabase/functions/<domain>/index.ts 형태로만 생성한다.
- 공통 로직은 supabase/functions/_shared/* 에만 둔다.

[응답]
- 코드/규칙/스펙은 복붙 가능한 텍스트로만 출력한다.
- 요구사항이 문서에 없으면 구현하지 말고, “추측입니다”로 표시 후 필요한 정보만 나열한다.