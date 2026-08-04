---
description: 현재 세션을 TIL Daily(STAR)에 병합하고 기술 학습은 knowledge로 승격, 승인 시 커밋·푸시까지
argument-hint: "[--deep] [--dry-run] [--date YYYY-MM-DD]"
allowed-tools: Bash(date:*), Bash(pwd), Bash(ls:*), Bash(test:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git config:*), Bash(git branch:*), Bash(git add:*), Bash(git commit:*), Bash(git pull:*), Bash(git push:*), Read, Write, Edit, Glob, Grep
---

<!-- 권장 effort: high (문서 2종을 쓰고 git 조작까지 하므로 medium에서는 knowledge 서술이 얕아진다) -->

# /summarize — 세션 → TIL 반영 → 커밋·푸시

## 출력 규칙 (fluff: terse)
인사·자기설명·"~해드릴게요" 금지. 게이트 질문, 승인 요약, 최종 보고만 출력한다.
승인 없이 파일을 쓰거나 커밋·푸시하지 않는다.

## CONFIG (유지보수 지점 — 값이 바뀌면 여기만 고친다)

> **처음 쓰기 전에 아래 4줄을 본인 값으로 고쳐라.** 특히 `TIL_ROOT`는 실제 TIL
> 저장소 경로여야 한다. STEP 0에서 존재 확인에 실패하면 그냥 중단한다.

```
TIL_ROOT       = $HOME/til              # ← 본인 TIL 저장소 경로
DAILY          = $TIL_ROOT/daily/<date>.md
KNOW           = $TIL_ROOT/knowledge/<도메인>/<개념>.md
GIT_USER_NAME  = <your-git-username>    # ← 본인 값
GIT_USER_EMAIL = <your-git-email>       # ← 본인 값. TIL이 개인 저장소면 개인 메일이 정상
GIT_BRANCH     = main
COMMIT_STYLE   = Conventional Commits (예: docs(til): ...)
```

`$TIL_ROOT/star`(Daily 템플릿 생성 스크립트)를 STEP 4에서 실행한다. 매번 권한을
묻지 않게 하려면 프론트매터 `allowed-tools`에 `Bash(<TIL_ROOT>/star)`를 추가하라.

## 옵션
- `--deep` : 겪은 어려움/의사결정을 서술형으로. 기본은 간결.
- `--dry-run` : 승인 요약까지만. 파일 안 쓰고 커밋도 안 함.
- `--date YYYY-MM-DD` : 대상 Daily 날짜. 미지정이면 오늘. **자정을 넘겨 작업한 세션은 작업 시작일을 넘길 것.**

---

## STEP 0 — 부트스트랩 자기점검

- 오늘: !`date +%F`
- 현재 위치: !`pwd`
- 현재 repo 변경: !`git status --short 2>/dev/null | head -50 || echo "(git repo 아님)"`
- 변경 규모: !`git diff --stat HEAD 2>/dev/null | tail -30`
- Daily 최근: !`ls -1 "${TIL_ROOT:-$HOME/til}/daily" 2>/dev/null | tail -5`
- knowledge 도메인: !`ls "${TIL_ROOT:-$HOME/til}/knowledge" 2>/dev/null`

`TIL_ROOT`가 없으면 **중단**하고 경로를 되묻는다. 추측해서 만들지 않는다.

## STEP 1 — 세션 요약 (내부 정리, 출력하지 않음)

이 세션의 대화를 근거로 5개 축을 채운다. 근거 없는 항목은 **비워 둔다. 추측 금지.**

1. 한 업무 — 무엇을 하려 했는가
2. 겪은 어려움 — 어디서 막혔고 왜 막혔는가
3. 의사결정 및 문제해결 방식 — 후보안, 고른 이유, 버린 이유
4. 배운 점·느낀 점 — 원리 수준으로 새로 알게 된 것
5. 수정한 파일 경로

## STEP 2 — 수정 파일 확정 (교차검증)

세션 기억과 STEP 0의 `git status`/`git diff --stat` 실측을 대조한다.
- 양쪽에 있음 → 확정
- git에만 있음 → 포함하되 `(세션 외 변경 가능)` 표시
- 세션 기억에만 있음 → repo 밖이거나 미저장. 포함하고 근거를 밝힘
- git repo가 아니면 세션 기억으로 폴백하고 그 사실을 보고에 적는다

파일을 `knowledge/` 대상과 **업무 repo 대상**으로 분류한다.

## STEP 3 — knowledge 승격 판별

STEP 1의 4번 중 **기술 원리에 해당하는 것**만 승격한다. 단순 작업 로그·환경 삽질기는 승격하지 않는다.

각 항목마다:
1. `Glob`/`Grep`으로 기존 도메인에 같은 개념 문서가 있는지 **먼저** 찾는다
2. 있으면 **갱신** (기존 내용 삭제 없이 섹션 추가·보강)
3. 없으면 적합한 기존 도메인에 신규 생성
4. 적합한 도메인이 하나도 없을 때만 새 도메인 폴더 신설 — **STEP 5에서 별도 승인**

내용은 `TIL_GUIDELINES.md` B항을 따른다: 동작 원리(First Principles), 코드 예제, 예외 케이스, 표·다이어그램.

## STEP 4 — Daily 문서 확보

`test -f $DAILY` 확인.
- 없으면 `$TIL_ROOT/star` 실행 (`daily/<오늘>.md` 템플릿 생성)
- `--date`가 오늘이 아니고 그 파일도 없으면 → `star`는 오늘 것만 만든다. **중단하고 알린다.**
- 있으면 `Read`로 전문을 읽는다

읽은 뒤 분기:
- **템플릿 플레이스홀더 상태**(`* 어떤 기능/실험을 하다가...`, `* 예: [...]`, 표의 `knowledge/도메인/파일명.md` 행) → 그 줄을 **교체**한다. 밑에 덧붙이면 안 된다.
- **이미 채워진 상태** → 기존 항목과 대조해 **이미 적힌 것은 스킵**, 신규만 이어붙인다. Situation & Task는 기존 번호를 이어서(7, 8...).

업무 repo 파일이 있으면 `지식 문서 수정 기록` 표 아래에 다음 표를 신설한다 (기존 표는 knowledge 전용으로 유지):

```
## 작업 파일 변경

| 저장소 | 파일 | 작업 |
|---|---|---|
```

## STEP 5 — 승인 게이트 (딱 이 형식으로만 출력)

```
[Daily] daily/<date>.md  (신규 생성 | 기존 병합)
<작성 내용 요약 3~4줄. STAR 전문 나열 금지>

[knowledge] 신규 M / 갱신 K
  신규  knowledge/<도메인>/<파일>.md   — 한 줄 요지
  갱신  knowledge/<도메인>/<파일>.md   — 한 줄 요지
<새 도메인 신설이 있으면: ⚠ 새 도메인 '<이름>' 신설>
<중복으로 스킵한 항목이 있으면: 스킵  <항목>>

이대로 쓸까요? (yes / 수정요청)
```

`--dry-run`이면 여기서 종료. yes 이전에는 쓰지 않는다.

## STEP 6 — 쓰기

1. knowledge 문서 (신규 `Write`, 갱신 `Edit`)
2. Daily 문서 `Edit` — STAR 병합 + 표 갱신
3. **기존 문장을 지우는 편집 금지.** 교체는 STEP 5에서 밝힌 플레이스홀더 줄에 한한다

## STEP 7 — git 아이덴티티 검증 (게이트)

`TIL_ROOT`에서 확인한다:
- `git config --get user.name` == `GIT_USER_NAME`
- `git config --get user.email` == `GIT_USER_EMAIL`
- `git branch --show-current` == `GIT_BRANCH`

**원격 URL은 절대 출력하지 않는다.** `https://<user>:<token>@github.com/...` 형태로
origin에 PAT가 평문으로 박혀 있는 경우가 흔하다. `git remote -v`를 그대로 찍지 말 것.

불일치가 하나라도 있으면 **커밋하지 않고 중단**한다. 실제값과 기대값을 나란히 보여주고, `user.email`이 repo-local에 고정돼 있지 않아 global에서 흘러들어온 경우라면 그 사실을 명시한다. 사용자 지시 없이 `git config`로 값을 고치지 않는다.

## STEP 8 — 커밋·푸시 선택 (게이트)

`COMMIT_STYLE`에 맞춘 커밋 메시지를 **1개 추천**하고, 스테이징할 파일을 나열한 뒤 선택지를 준다.

```
아이덴티티 OK  <name> / <email> / <branch>

추천 커밋:
  docs(til): <요지>

스테이징:
  daily/<date>.md
  knowledge/<도메인>/<파일>.md

1) 커밋 + 푸시
2) 커밋만
3) 안 함 (파일은 이미 저장됨)
```

선택 시 동작:
- **1)** `git add <위 경로들만>` → `git commit -m "<추천 메시지>"` → `git pull --no-rebase --no-edit origin main` → `git push origin main`
- **2)** `git add` + `git commit`까지만
- **3)** 아무것도 하지 않고 STEP 9로

규칙:
- `git add .` 금지 — **위에 나열한 경로만** 스테이징한다. 무관한 변경을 끌어들이지 않기 위함.
- `./push`(= `scripts/auto_push.sh`)는 쓰지 않는다. 그 스크립트는 `git add .` 후 메시지를 `<날짜> daily commit`으로 **하드코딩**해서 추천 메시지를 덮어쓴다.
- pull은 반드시 `--no-rebase`. rebase로 당기면 머지 커밋이 조용히 사라진다.
- push 실패 시 재시도하거나 `--force`를 쓰지 않는다. 에러 원문을 그대로 보여주고 멈춘다.

## STEP 9 — 보고 및 Grill 제안

```
Daily:  daily/<date>.md  (+N줄)
knowledge:
  신규  <경로>
  갱신  <경로>
git:    커밋 <sha7> / 푸시 완료 | 커밋만 | 안 함
```

수행하지 않은 단계는 "안 함"으로 정직하게 적는다. 푸시가 실패했으면 성공으로 적지 않는다.

마지막에 `TIL_GUIDELINES.md` 3-4항에 따라, 오늘 정리한 개념으로 **다음 복습 때 던질 심화 질문 2개**를 제안한다.

## 예외
- `TIL_ROOT` 부재 → 중단, 되묻기
- 요약할 기술 내용 없음 → "기록할 내용 없음" 한 줄 출력하고 종료. 빈 섹션을 채우지 않는다
- `--date` 대상 Daily 없고 오늘이 아님 → 중단, 알림
- git repo 아님 → 세션 기억 폴백 + 보고에 명시
- git 아이덴티티 불일치 → STEP 7에서 중단, 자동 수정 금지
- 원격 URL 출력 금지 (PAT 평문)
