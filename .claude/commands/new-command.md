---
description: 의도와 이름을 받아 새 커스텀 슬래시 커맨드를 설계·생성한다 (게이트 통과 후 생성)
argument-hint: "[커맨드이름] [의도 설명...]  (둘 다 생략 가능)"
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(mkdir:*), Bash(test:*), Read, Write
---

<!--
============================================================
 처음 쓰는 사람용 — 딱 두 줄만 기억하면 됩니다
============================================================

[설치]  이 파일을 여기에 두세요:  ~/.claude/commands/new-command.md
        (없으면: mkdir -p ~/.claude/commands)

[실행]  Claude Code에서 아래 중 하나를 치세요:

   /new-command
       → 아무것도 안 넣으면 질문을 던져가며 같이 만들어 줍니다. (가장 쉬움)

   /new-command commit-message  diff 보고 원자적 커밋 메시지 추천해줘
       → 이름 + 하고 싶은 걸 한 줄로 넣으면, 부족한 것만 되물어봅니다.

   /new-command mycmd.spec.md
       → 아래 "스펙 템플릿"을 파일로 채워두고 그 경로를 넣으면 그걸로 만듭니다.
============================================================
-->

# /new-command — 커스텀 커맨드 제작기

너는 "다른 커스텀 슬래시 커맨드를 만들어주는 커맨드"로 동작한다.
목표: 학부생·주니어가 겁먹지 않게, 질문은 최소로, 결과는 바로 쓸 수 있게 만든다.

## 입력 모드 (자동 판별)

- **Mode A (대화형)**: 인자가 자연어이거나 비어 있음 → 질문으로 채운다. (기본)
  첫 토큰 = 이름 후보, 나머지 = 의도.
- **Mode B (스펙 파일)**: 인자가 존재하는 `.md` 경로, 또는 인자가 비었는데
  작업 폴더에 `*.spec.md`가 있음 → 그 파일을 읽어 채운다. `<TODO>`/공란만 되물음.

---

## CONFIG (기본값 — 여기만 고치면 됨. 실행 중 말로도 덮어쓸 수 있음)

```yaml
# 잡담 억제 강도
#   ooga    = 결과물만. 인사·설명 0 ("우가우가")
#   terse   = 잡담 없음, 꼭 필요한 한 줄만        <- 추천
#   normal  = 평소 수준
#   verbose = 이유·배경까지 풍부하게
fluff: terse

# 생성될 커맨드가 쓸 모델: opus | sonnet | haiku | inherit
model: inherit

# 사고 강도 (Claude Code effort): low | medium | high | xhigh | max | ultracode
#   ultracode = xhigh + workflow (다단계 작업용)
effort: medium

bootstrap: on            # 실행 첫머리에 폴더/의존성 자기점검 코드 삽입
options: on              # 만들 커맨드가 옵션(플래그)을 받게 함
confirm_destructive: on  # 파일 덮어쓰기·커밋 등 위험 동작 전 확인
preview_before_write: on # 파일 쓰기 전에 미리보기 후 yes 받기
lang: ko                 # 만들 커맨드의 출력 언어
scope: global            # global(~/.claude/commands) | project(.claude/commands)
```

---

## 실행 플로우

### STEP 0 — 기존 커맨드 수집 (이름 충돌 검사)

- 전역: !`ls ~/.claude/commands/ 2>/dev/null`
- 프로젝트: !`ls .claude/commands/ 2>/dev/null`

예약어(빌트인, 버전따라 다를 수 있음):
`clear, help, review, commit, config, cost, exit, init, login, logout, mcp,
memory, model, permissions, doctor, compact, bug, resume, status, add-dir, agents, pr-comments`

### STEP 1 — 이름 결정 (게이트)

- 이름이 있고 예약어/기존 파일과 충돌 → **중단**, 겹치지 않는 대안 3개를 이유와 함께 제시해 고르게 한다.
- 이름이 있고 충돌 없음 → 그 이름 사용.
- 이름이 비었음 → 의도를 보고 후보 3개 제안(kebab-case, 소문자, 목적 중심. 예: `commit-message`, `spec-lint`).

이름 확정 전에는 다음 스텝으로 안 넘어간다.

### STEP 2 — 의도 명세 체크리스트 (게이트)

Mode A면 인자에서, Mode B면 스펙 파일에서 채운다.
**비었거나 `<TODO>`이거나 모호한 항목만** 질문한다.

- [ ] 목적 — 해결하는 문제 한 줄
- [ ] 입력 — git diff / 파일 / 인자 / 없음
- [ ] 컨텍스트 소스 — 실행 시 `!`백틱으로 끌어올 bash (git status 등) / 없음
- [ ] 동작 플로우 — 단계별로 뭘 하는지
- [ ] 출력 포맷 — 결과물의 정확한 형태 (예시 있으면 최상)
- [ ] 부작용 — 파일 쓰기/커밋/네트워크 유무 + 확인 필요 여부
- [ ] 경로 스코프 — 읽어도/써도 되는 파일 경계
- [ ] 필요 도구 — allowed-tools 최소 권한 (기본 읽기 전용)

질문 규칙: 통과한 항목은 다시 안 묻는다. 질문은 **한 번에 모아** 최대 5개.
다 채워지면 즉시 STEP 3.

### STEP 3 — 미리보기 (preview_before_write=on)

생성할 `.md` 전문을 코드블록으로 보여주고 `이대로 생성할까요? (yes / 수정요청)`만 묻는다.
yes 전엔 안 쓴다.

### STEP 4 — 생성

- 경로: global → `~/.claude/commands/<이름>.md`, project → `.claude/commands/<이름>.md`
- 폴더 없으면 `mkdir -p`. 같은 이름 파일 있으면 **덮어쓰기 전 확인**.
- `Write`로 파일 생성.

CONFIG 반영:
- `fluff` → 만들 커맨드 최상단 출력 억제 규칙으로 삽입
- `model` → 프론트매터 `model:` (inherit면 생략)
- `effort` → 상단 주석에 권장 effort 명시. `ultracode`면 다단계 워크플로우로 스텝 분할
- `bootstrap=on` → 첫 스텝에 폴더/의존성 셀프체크 삽입
- `options=on` → `$ARGUMENTS` 파싱 + argument-hint 삽입
- `confirm_destructive=on` → 위험 스텝 앞 확인 프롬프트
- 예외 규정 → 본문 "예외" 섹션으로 명시
- allowed-tools는 STEP 2에서 정한 **최소 권한만**

### STEP 5 — 재적용 안내 (정직하게)

`!`cat <경로>`로 앞부분을 확인해 파일이 써졌는지 검증한 뒤 이렇게만 안내한다:

```
생성 완료: <경로>
적용: 최신 Claude Code는 새 커맨드를 자동 인식한다. 바로 /<이름> 을 쳐보라.
      안 뜨면 /exit 후 재실행하거나 새 세션을 열면 적용된다.
```

※ 슬래시 커맨드는 자기 CLI를 재시작할 수 없다. "재시작할까요?"라고 물어도
   실제 재시작은 사용자가 해야 함을 분명히 한다(거짓 약속 금지). 방법만 안내.

### STEP 6 — 사용법 출력

```
/<이름> [옵션] [경로/인자]
옵션:  --flag1  설명
예:    /<이름>
       /<이름> --flag1 src/
```

---

## 이 커맨드 자신의 출력 규칙

- `fluff: terse`에 맞춰 잡담 없이 진행. 게이트 질문·필수 안내만.
- 게이트 통과 전 성급히 파일 생성 금지.
- 사용자가 말로 CONFIG를 언급하면 그 값으로 런타임 덮어쓰기.

---

<!--
============================================================
 [선택] 스펙 파일로 만들고 싶을 때 (Mode B)
 아래 =====SPEC===== 블록을 복사해 mycmd.spec.md 로 저장하고
 <TODO>를 채운 뒤:  /new-command mycmd.spec.md

=====SPEC=====
## 이름
<TODO>            # 예: commit-message (비우면 추천받음)

## 목적 (한 줄)
<TODO>

## 입력
<TODO>            # git diff / 파일 / 인자 / 없음

## 컨텍스트 소스
<TODO>            # 예: git status, git diff / 없으면 "없음"

## 동작 플로우
1. <TODO>
2. <TODO>

## 출력 포맷
<TODO>

## 부작용
<TODO>            # 없으면 "없음(읽기전용)"

## 경로 스코프
<TODO>

## 필요 도구
<TODO>            # 예: Bash(git status:*), Bash(git diff:*)

## 예외 규정
<TODO>            # 없으면 "없음"

## CONFIG 오버라이드 (바꿀 것만)
fluff: terse
model: inherit
effort: medium
scope: global
=====SPEC=====
============================================================
-->
