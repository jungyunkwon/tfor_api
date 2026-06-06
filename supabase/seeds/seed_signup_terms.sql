insert into public.tb_terms (
    terms_type_cd,
    terms_version,
    terms_title,
    terms_content,
    required_yn,
    current_yn,
    effective_start_dt,
    del_yn
)
values
(
    'PRIVACY',
    '1.0',
    '개인정보 이용 동의 약관',
    '개인정보 이용 동의 약관

1. 수집 항목
- 이메일, 닉네임, 성별, 출생연도, 지역, 프로필 정보, 사진, 설문 응답

2. 이용 목적
- 회원 식별 및 가입 처리
- 프로필 작성 및 매칭 서비스 제공
- 서비스 운영, 고객 문의 대응, 부정 이용 방지

3. 보유 및 이용 기간
- 회원 탈퇴 시까지 보관합니다.
- 관계 법령에 따라 보관이 필요한 정보는 해당 기간 동안 보관할 수 있습니다.

4. 동의 거부 권리
- 사용자는 개인정보 수집 및 이용에 동의하지 않을 수 있습니다.
- 단, 필수 개인정보 이용에 동의하지 않으면 회원가입 및 서비스 이용이 제한됩니다.',
    'Y',
    'Y',
    now(),
    'N'
),
(
    'MARKETING',
    '1.0',
    '마케팅 이용약관',
    '마케팅 이용약관

1. 수신 항목
- 이벤트, 혜택, 프로모션, 신규 기능 및 서비스 안내

2. 수신 방법
- 앱 푸시, 이메일, 알림 메시지 등 서비스에서 제공하는 수단

3. 이용 목적
- 이벤트 및 혜택 안내
- 맞춤형 서비스 및 프로모션 정보 제공
- 서비스 만족도 향상을 위한 안내

4. 보유 및 이용 기간
- 마케팅 수신 동의 철회 또는 회원 탈퇴 시까지 보관합니다.

5. 동의 거부 권리
- 사용자는 마케팅 정보 수신에 동의하지 않을 수 있습니다.
- 마케팅 수신 동의를 거부해도 기본 서비스 이용에는 제한이 없습니다.',
    'N',
    'Y',
    now(),
    'N'
)
on conflict (terms_type_cd, terms_version)
do update set
    terms_title = excluded.terms_title,
    terms_content = excluded.terms_content,
    required_yn = excluded.required_yn,
    current_yn = excluded.current_yn,
    effective_start_dt = excluded.effective_start_dt,
    update_dt = now(),
    del_yn = excluded.del_yn
returning
    terms_id,
    terms_type_cd,
    terms_version,
    terms_title,
    required_yn,
    current_yn,
    del_yn;
