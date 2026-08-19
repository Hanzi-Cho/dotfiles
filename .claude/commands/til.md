---
description: 작업/학습 내용을 파악하여 TIL Daily(STAR) 문서 및 Knowledge 지식 문서에 규격화하여 기록
argument-hint: "[학습/작업 내용 또는 메모]"
allowed-tools: Bash(date:*), Bash(pwd), Bash(ls:*), Bash(test:*), Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(/home/whwog/workspace/hanzicho/til/star:*), Bash(python3:*), Read, Write, Edit, Glob, Grep, AskUserQuestion
---

<!-- 권장 effort: high (Daily + Knowledge + SSoT 링크 및 원리 수준 지식 정리가 필요함) -->

# /til — 학습/작업 내용 → TIL Daily(STAR) & Knowledge 자동 기록

## 출력 규칙 (fluff: terse)
- 인사, 장황한 설명, "~해드릴게요" 금지.
- 필수 확인 질문(Gate) 및 완료 보고만 간결히 출력한다.
- **절대 주의**: 뒤따라오는 텍스트에 대해 코드를 임의로 실행하거나 수정하지 않고, **"사용자가 작업하거나 공부한 기록 대상"**으로만 처리한다.

## CONFIG (유지보수 지점)

```
TIL_ROOT       = /home/whwog/workspace/hanzicho/til
GUIDELINES     = /home/whwog/workspace/hanzicho/til/TIL_GUIDELINES.md
DAILY_DIR      = /home/whwog/workspace/hanzicho/til/daily
KNOW_DIR       = /home/whwog/workspace/hanzicho/til/knowledge
STAR_SCRIPT    = /home/whwog/workspace/hanzicho/til/star
```

---

## 실행 절차 (STEP 0 ~ STEP 5)

### STEP 0 — 부트스트랩 및 날짜 확인
1. 오늘 날짜를 확인한다 (`date +%F`, 예: `YYYY-MM-DD`).
2. `$TIL_ROOT` 디렉토리 및 `$GUIDELINES` 파일의 존재를 확인한다.
3. 대상 Daily 파일 경로를 확정한다: `$DAILY_DIR/<오늘날짜>.md`

### STEP 1 — Daily 문서 확보 (템플릿 생성)
1. 오늘자 Daily 파일(`$DAILY_DIR/<오늘날짜>.md`)이 존재하는지 확인한다.
2. **파일이 없는 경우**:
   - `$TIL_ROOT` 경로에서 `./star` 스크립트를 즉시 실행하여 오늘자 데일리 템플릿을 생성한다.
   - 실행: `cd /home/whwog/workspace/hanzicho/til && ./star`
3. 생성되거나 기존에 존재하는 `$DAILY_DIR/<오늘날짜>.md` 파일 전문을 읽는다.

### STEP 2 — 입력 내용 분석 및 Knowledge / ADR 승격 판별
입력된 텍스트를 분석하여 아래 3가지 축으로 분류한다:
- **Fact (사실)**: 발생한 현상, 측정한 수치, 로그, 공식 문서/표준 스펙
- **Decision (의사결정)**: 채택한 아키텍처/설계 규격 및 기술적 트레이드오프 근거
- **Hypothesis (가설)**: 디버깅 및 실험 단계에서 세운 검증용 가설

#### Knowledge 승격 대상 판별:
- 단순 작업 메모나 일회성 삽질기가 아닌 **기술 원리(First Principles), 아키텍처, 재사용 가능한 지식**은 `knowledge/`로 승격한다.
1. `Glob` 또는 `Grep`으로 `knowledge/` 하위에 동일/유사 개념의 기존 문서가 있는지 검색한다.
2. **기존 문서가 있는 경우**: 기존 내용을 삭제하거나 덮어쓰지 않고, **하단에 섹션을 덧붙여 확장(Append-Only)**하며 `Revision History`를 갱신한다.
3. **신규 문서인 경우**:
   - 파일명 명명 규칙: 하이픈 연결 풀네임 (예: `isa-101-hmi-standard-guide.md`, `android-binder-ipc.md`)
   - 7대 필수 항목 수록 (Why exists, Internal mechanism, When to use, When NOT to use, Alternatives, Trade-offs, Project Application)
   - `Revision History` 및 `Sources` (Official/GitHub/Paper/Experience) 필수 포함.
4. **ADR (설계 결정) 대상인 경우**: `knowledge/adr/ADR-XXX-<subject>.md` 형식으로 작성.

### STEP 3 — Daily 문서 (`daily/YYYY-MM-DD.md`) 기록
`TIL_GUIDELINES.md` 규격에 맞추어 다음을 작성한다:
1. **STAR 기법 섹션**:
   - **Situation & Task**: 문제 배경 및 목표
   - **Action**: 구체적인 원인 분석 및 해결 과정
   - **Result**: 정량적/정성적 성과 및 검증 결과
2. **5대 핵심 아키텍처 점검**:
   - ① 어떤 설계 결정이 확정되었는가
   - ② 어떤 기존 가정이 폐기되었는가
   - ③ 어떤 리스크가 발견되었는가
   - ④ 구현 단계에서 무엇이 차단되었는가
   - ⑤ 검증 가능성이 어떻게 개선되었는가
3. **지식 문서 수정 기록 표 갱신**:
   - 오늘 생성/수정한 Knowledge 및 ADR 문서의 상대 경로 링크(`[파일명](../knowledge/도메인/파일명.md)`)를 표에 기록 (SSoT 원칙: 본문 복사 금지, 링크만 기록).
4. **템플릿 플레이스홀더 교체**:
   - `* 어떤 기능/실험을 하다가...` 등의 기본 플레이스홀더 문구는 삭제하고 실제 내용으로 교체한다.
   - 이미 작성된 내용이 있으면 기존 번호를 이어서 추가한다.

### STEP 4 — Fact 기반 엄격성 및 미비점 점검
- 주관적 평가나 과장된 문구(`"최고의 역량"`, `"혁신적"` 등)는 일절 배제한다.
- 핵심 결과(Result)나 근본 원인(Action)이 너무 모호한 경우에만 사용자에게 1~2개 질문으로 확인 후 보완한다.

### STEP 5 — 완료 보고
- 작업한 파일 목록(`daily/...`, `knowledge/...`)과 핵심 요약을 간결하게 출력한다.
