---
description: 프로젝트 아이디어 기획 또는 관심 기술(Tech Radar)을 분류하여 Idea Vault에 규격화하여 기록/갱신
argument-hint: "[아이디어 기획 내용 또는 사용해보고 싶은 기술 메모]"
allowed-tools: Bash(date:*), Bash(pwd), Bash(ls:*), Bash(find:*), Bash(test:*), Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git -C:*), Bash(python3:*), Read, Write, Edit, Glob, Grep, AskUserQuestion
---

<!-- 권장 effort: medium ~ high (아이디어 아키텍처 구상 및 README 동기화) -->

# /vault — 프로젝트 아이디어 & 관심 기술 → Idea Vault 자동 기록

## 출력 규칙 (fluff: terse)
- 인사, 장황한 설명, 불필요한 미사여구 금지.
- 분류 판별 결과, 대상 파일 경로, 수정 내역 요약만 간결히 출력한다.

## CONFIG (유지보수 지점)

```
VAULT_ROOT     = /home/whwog/workspace/hanzicho/idea-vault
RULES_DOC      = /home/whwog/workspace/hanzicho/idea-vault/.agent/AGENTS.md
TEMPLATE_FILE  = /home/whwog/workspace/hanzicho/idea-vault/templates/idea_template.md
SYNC_SCRIPT    = /home/whwog/workspace/hanzicho/idea-vault/scripts/update_readme.py
TECH_RADAR_DIR = /home/whwog/workspace/hanzicho/idea-vault/tech-stack
```

---

## 핵심 원칙 (중복 방지 & 체계적 관리)

> [!IMPORTANT]
> **중복 파일 생성 엄격 금지**: 새로운 아이디어나 기술이 들어오면 반드시 기존 문서를 먼저 검색(`find`, `grep`)한다. 기존 아이디어의 발전/피드백인 경우 새 파일을 만들지 않고 **기존 문서를 수정·보강**하며 최하단 `## 📝 업데이트 로그`에 이력을 누적한다.

---

## 실행 절차 (STEP 0 ~ STEP 5)

### STEP 0 — 부트스트랩 및 저장소 확인
1. `$VAULT_ROOT` 및 `$RULES_DOC`, `$TEMPLATE_FILE`의 존재를 확인한다.
2. 디렉토리 구조 및 기존 아이디어 목록을 스캔한다.

### STEP 1 — 입력 텍스트 양상 판별 (Classification)
슬래시 커맨드 뒤에 오는 텍스트의 성격을 아래 3가지 중 하나로 판별한다:

| 분류 | 판별 기준 | 처리 방향 |
|---|---|---|
| **Type A. 프로젝트 아이디어 기획** | 특정 서비스, 제품, 게임, 공공툴, 비즈니스 BM, PoC 아키텍처 구상 | `startup/`, `side-project/`, `game-dev/`, `public-contribution/` 계층에 문서 작성/갱신 |
| **Type B. 관심 기술 스택 (Tech Radar)** | 써보고 싶은 프레임워크, 라이브러리, 저수준 기술, 인프라, 툴 | `tech-stack/` 하위 레벨별 문서(`level-1`, `level-2`, `level-3`)에 등록/갱신 |
| **Type C. 복합 (아이디어 + 기술)** | 신규 프로젝트 구상과 함께 도입할 핵심 신기술이 함께 언급됨 | 아이디어 문서 생성/보강 + 핵심 신기술을 `tech-stack/`에 동시 동기화 |

---

### STEP 2 — 분류별 세부 처리

#### [Type A / Type C: 프로젝트 아이디어 처리]
1. **카테고리 및 세부분야 식별**:
   - `startup/` (`b2b-saas`, `ai-platform` 등)
   - `side-project/` (`devtools`, `automation`, `car-tech`, `ai-engine`, `mobile-tech` 등)
   - `game-dev/` (`indie-engine`, `graphics-poc` 등)
   - `public-contribution/` (`open-data`, `civic-tech` 등)
2. **중복 검사 (No Duplicates)**:
   - `find $VAULT_ROOT -name "*.md"` 및 `grep`으로 유사 아이디어가 이미 존재하는지 검색.
3. **문서 작성 / 갱신**:
   - **기존 아이디어가 있는 경우**: 기존 문서 본문을 개선·확장하고, 최하단 `## 📝 업데이트 로그 (Update Log)` 테이블에 날짜(`YYYY-MM-DD`), 작업 구분, 상세 내용을 추가.
   - **신규 아이디어인 경우**: `$TEMPLATE_FILE` 템플릿 규격을 기반으로 파일명(kebab-case 풀네임) 생성 후 작성:
     - 1줄 프로젝트 의의 / 모티브
     - 핵심 요구사항 및 주요 기능
     - **AI 구현용 추천 기술 스택 및 아키텍처 다이어그램/인터페이스 제안**
     - 업데이트 로그 최초 등록

#### [Type B / Type C: 관심 기술 스택 처리]
1. **기술 성숙도 레벨 매핑**:
   - `tech-stack/level-1-wishlist.md`: 해보고 싶음 (Wishlist & Research)
   - `tech-stack/level-2-planned.md`: 적용/사용 계획 있음 (Planned & Architecture)
   - `tech-stack/level-3-experienced.md`: 실무/사이드 프로젝트에서 검증 완료 (Experienced & Proven)
2. **기존 기술 중복 확인**:
   - 해당 파일 및 타 레벨 파일에 이미 등록되어 있는지 검색.
   - 기존에 있으면 내용 보강 또는 레벨 승격(Level 1 $\to$ Level 2 $\to$ Level 3).
   - 신규 기술이면 적절한 대분류 섹션 하위에 핵심 특징 및 학습/활용 목적을 명확히 기재.

---

### STEP 3 — README 자동 동기화 실행 (필수)
아이디어 문서나 기술 스택 문서가 추가/수정된 후, 반드시 동기화 스크립트를 실행한다:
```bash
python3 /home/whwog/workspace/hanzicho/idea-vault/scripts/update_readme.py
```
- 스크립트 실행 결과 최상위 `README.md` 및 분야별 `README.md`의 프로젝트 리스트/통계가 정상 갱신되었는지 확인한다.

---

### STEP 4 — Git 변경 확인 및 커밋
1. `git -C /home/whwog/workspace/hanzicho/idea-vault status --short`로 변경사항 확인.
2. Conventional Commits 형식으로 스테이징 및 커밋:
   - 신규 아이디어: `feat(vault): add <아이디어명> specification`
   - 아이디어 수정: `docs(vault): update <아이디어명> - <변경내용>`
   - 기술 스택 추가: `feat(tech-stack): add <기술명> to level-X`
3. 원격 저장소(`origin main`)로 푸시.

---

### STEP 5 — 완료 보고
- 판별된 유형(Type A/B/C) 및 생성/수정된 파일 경로, 커밋 결과를 간결하게 보고한다.
