# dotfiles — Claude Code & Antigravity 커스텀 스킬·슬래시 커맨드 허브

> **반복되는 작업을 Claude Code 슬래시 커맨드와 Antigravity(AGY) 스킬로 표준화하고, 학습 지식(TIL)과 프로젝트 아이디어(Idea Vault)를 자동으로 축적합니다.**
>
> *Standardize workflows with Claude Code commands & Antigravity skills. Persist your knowledge and project ideas beyond sessions.*

WSL2 + tmux + React Native / Android 환경의 셸 설정과, **Claude Code 및 Antigravity(Google DeepMind AGY) 커스텀 슬래시 커맨드/에이전트 스킬**을 한 곳에서 관리합니다.

---

## ⚡ 3초 퀵스타트 (Quick Start)

### 1. 🤖 AI 에이전트에게 셋업 맡기기 (One-Shot Prompt)

새 머신이나 작업 환경에서 AI(Claude Code, Antigravity, Cursor 등)에게 아래 한 줄을 그대로 전달하면 모든 세팅이 자동 완료됩니다:

> ```text
> https://github.com/Hanzi-Cho/dotfiles 저장소를 참고해서 내 환경에 Claude Code 슬래시 커맨드 및 Antigravity 커스텀 스킬(/til, /vault, /commit, /summarize)을 설치하고, 연계 학습 저장소(TIL)와 아이디어 보관소(Idea Vault)의 기본 틀을 자동으로 구축해줘.
> ```

---

### 2. 💻 터미널 원터치 설치 (Copy & Paste)

- **슬래시 커맨드 & 에이전트 스킬만 설치 (권장)**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/Hanzi-Cho/dotfiles/main/install.sh | bash -s -- --commands-only
  ```
  `~/.dotfiles`에 저장소를 클론하고 `~/.claude/commands/` (Claude Code) 및 `~/.gemini/config/skills/` (Antigravity)에 심볼릭 링크를 자동 연결합니다.

- **셸 설정(`bashrc.d`, `zshrc.d`, `bin/`) 포함 전체 설치**:
  ```bash
  git clone https://github.com/Hanzi-Cho/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
  ```

---

## 📦 핵심 커맨드 & 스킬 5종 (Overview)

각 커맨드/스킬은 독립적이며, **Claude Code**와 **Antigravity** 양쪽 환경에서 모두 매핑되어 동작합니다.

| 커맨드 / 스킬 | 지원 환경 | 주요 역할 및 특징 | 사용 예시 |
|:---|:---:|:---|:---|
| **`/til`** | Claude Code<br>Antigravity | 작업/공부 내용을 **TIL Daily(STAR) & Knowledge 문서**에 자동 기록. 코드 수정 없이 학습 기록으로 안전하게 격리. | `/til [작업/학습 내용 메모]` |
| **`/vault`** | Claude Code<br>Antigravity | 프로젝트 아이디어 & 관심 기술(Tech Radar)을 **Idea Vault**에 중복 없이 분류/기록하고 README 자동 동기화. | `/vault [아이디어/기술 메모]` |
| **`/commit`** | Claude Code | `git diff`를 원자적 단위로 쪼개 Conventional Commits 메시지 추천/커밋/푸시. | `/commit` 또는 `/commit --push` |
| **`/summarize`** | Claude Code | 현재 세션에서 작업한 내용을 요약해 TIL에 남기고 기술 원리를 지식 문서로 자동 승격. | `/summarize` |
| **`/new-command`** | Claude Code | 명세 체크리스트와 게이트를 기반으로 안전하게 새 슬래시 커맨드를 설계·생성. | `/new-command [목적] [커맨드명]` |

---

## 🏗️ 연계 저장소 1초 생성기 (TIL & Idea Vault)

`/til`과 `/vault` 커맨드가 참조하는 2개의 독립 저장소 기본 구조를 즉시 생성하는 스크립트입니다. 터미널에 복사-붙여넣기 하세요.

### 1. 📚 학습 기록 저장소 (`~/til`) 생성
시간순 일지(Daily STAR)와 개념적 원리(Knowledge)를 분리하여 지식이 휘발되지 않도록 관리합니다.

```bash
mkdir -p ~/til/daily ~/til/knowledge
cd ~/til && git init -b main

# 오늘자 Daily 템플릿 생성 스크립트 (star)
cat > star <<'SH'
#!/usr/bin/env bash
set -euo pipefail
d="$(date +%F)"
f="$(dirname "$0")/daily/$d.md"
[ -f "$f" ] && { echo "already exists: $f"; exit 0; }
mkdir -p "$(dirname "$f")"
cat > "$f" <<EOF
# $d

## Situation & Task
1. 어떤 기능/실험을 하다가 무엇을 하려 했는지

## Action
- 막힌 지점과 그때 고른 방법, 버린 방법

## Result
- 결과와 배운 점

## 지식 문서 수정 기록

| 문서 | 신규/갱신 | 요지 |
|---|---|---|
| knowledge/챕터/파일명.md | 신규 | |
EOF
echo "created: $f"
SH
chmod +x star

# 가이드라인 문서 생성
cat > TIL_GUIDELINES.md <<'EOF'
# TIL Guidelines
- Daily는 STAR 기법(Situation, Task, Action, Result)으로 작성합니다.
- Knowledge는 재사용 가능한 기술 원리(First Principles) 중심으로 기록합니다.
- SSoT(Single Source of Truth): Daily에는 Knowledge 문서의 상대 링크만 남깁니다.
EOF

git add . && git commit -m "chore: initialize TIL repository"
```

---

### 2. 💡 아이디어 보관소 (`~/idea-vault`) 생성
창업·사이드프로젝트·게임개발·공공기여 아이디어 및 관심 기술 레이더(Tech Radar 3-Level)를 관리하고 README를 자동 동기화합니다.

```bash
mkdir -p ~/idea-vault/{startup,side-project,game-dev,public-contribution,tech-stack,templates,scripts}
cd ~/idea-vault && git init -b main

# 1) 표준 아이디어 템플릿
cat > templates/idea_template.md <<'EOF'
# [프로젝트 제목]: [한 줄 의의/목적]

> **1줄 요약 (Abstract)**: [프로젝트의 핵심 가치 및 목표를 한 문장으로 기재]

- **카테고리 (Category)**: `[startup | side-project | game-dev | public-contribution]`
- **세부 분야 (Field & Tech)**: `[b2b-saas | devtools | automation | indie-engine | open-data 등]`
- **목적 (Purpose)**: `[포트폴리오 | 취미 | 개인성장 | 공공기여 | 창업BM]`
- **상태 (Status)**: `[💡 Draft | 🔬 Research | 🛠️ PoC | 🚀 Active | 📦 Archived]`
- **구현 현황 (Implementation Level)**: `[기획 단계 | PoC 검증 완료 | 로컬 개발 중 | 서비스 배포]`
- **연관 링크 / 경로 (Links)**: `[GitHub Repo 또는 로컬 경로]`

---

## 1. 프로젝트 의의 및 배경 (Significance & Motive)
* **최상단 프로젝트 의의**: [이 프로젝트가 왜 존재해야 하는지 1줄 작성]
* **모티브 및 계기 (Motive)**: [이 아이디어를 착안하게 된 경험, 문제 의식]

---

## 2. 요구사항 및 주요 기능 (Requirements & Features)
### (1) 핵심 요구사항
1. [요구사항 1]
### (2) 주요 기능
* **Feature A**: [설명]

---

## 3. 추천 기술 스택 및 아키텍처 제안 (Tech Stack & Architecture)
### (1) Recommended Tech Stack
- **Frontend / UI**: [e.g. Next.js 15, React Native]
- **Backend / Core**: [e.g. Node.js, FastApi, Go]
- **Database / Infra**: [e.g. PostgreSQL, Redis, Docker]

---

## 📝 업데이트 로그 (Update Log)
| 날짜 (Date) | 작업 구분 | 상세 내용 |
|---|---|---|
| YYYY-MM-DD | 💡 최초 등록 | 아이디어 최초 구상 및 기본 명세 작성 |
EOF

# 2) Tech Radar 3-Level 문서
cat > tech-stack/level-1-wishlist.md <<'EOF'
# 🌟 Level 1: Wishlist & Research (써보고 싶은 기술)
EOF

cat > tech-stack/level-2-planned.md <<'EOF'
# 🎯 Level 2: Planned & Architecture (적용 계획 기술)
EOF

cat > tech-stack/level-3-experienced.md <<'EOF'
# 🚀 Level 3: Experienced & Proven (검증 완료 기술)
EOF

# 3) README 자동 갱신 스크립트
cat > scripts/update_readme.py <<'PY'
#!/usr/bin/env python3
import os, re

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATEGORIES = ["startup", "side-project", "game-dev", "public-contribution"]

def parse_idea(filepath):
    with open(filepath, "r", encoding="utf-8") as f: content = f.read()
    title_m = re.search(r"^#\s+(.+)$", content, re.M)
    title = title_m.group(1).strip() if title_m else os.path.basename(filepath)
    ab_m = re.search(r">\s*\*\*1줄 요약.*?\*\*:\s*(.+)$", content, re.M)
    abstract = ab_m.group(1).strip() if ab_m else "1줄 요약 미작성"
    field_m = re.search(r"-\s*\*\*세부 분야.*?\*\*:\s*`?(.*?)`?$", content, re.M)
    field = field_m.group(1).strip() if field_m else "일반"
    purp_m = re.search(r"-\s*\*\*목적.*?\*\*:\s*`?(.*?)`?$", content, re.M)
    purpose = purp_m.group(1).strip() if purp_m else "미지정"
    impl_m = re.search(r"-\s*\*\*구현 현황.*?\*\*:\s*`?(.*?)`?$", content, re.M)
    impl = impl_m.group(1).strip() if impl_m else "기획 단계"
    return {"title": title, "abstract": abstract, "field": field, "purpose": purpose, "impl": impl, "path": os.path.relpath(filepath, ROOT_DIR)}

def main():
    ideas = []
    for cat in CATEGORIES:
        cat_dir = os.path.join(ROOT_DIR, cat)
        if not os.path.exists(cat_dir): continue
        for r, _, fs in os.walk(cat_dir):
            for f in fs:
                if f.endswith(".md") and f != "README.md":
                    i = parse_idea(os.path.join(r, f))
                    i["cat"] = cat
                    ideas.append(i)
    
    content = f"# 💡 Idea Vault\n\n> **프로젝트 아이디어 & 관심 기술 레지스트리 (총 {len(ideas)}개)**\n\n"
    content += "| 프로젝트 | 분류 / 세부분야 | 목적 | 구현 현황 | 문서 |\n|---|:---:|:---:|:---:|:---:|\n"
    for i in ideas:
        content += f"| **{i['title']}** | `{i['cat']}` / `{i['field']}` | {i['purpose']} | {i['impl']} | [📄 보기](./{i['path']}) |\n"
    with open(os.path.join(ROOT_DIR, "README.md"), "w", encoding="utf-8") as f: f.write(content)
    print(f"Updated README for {len(ideas)} ideas.")

if __name__ == "__main__": main()
PY
chmod +x scripts/update_readme.py

python3 scripts/update_readme.py
git add . && git commit -m "chore: initialize Idea Vault repository"
```

---

## 🛠️ 커맨드별 상세 가이드

### 1. `/til` (Claude Code & Antigravity)
- **목적**: 작업 내용 또는 학습한 개념을 격리하여 **오늘자 일지(Daily STAR)**와 **지식 문서(Knowledge)**에 정밀 기록.
- **동작 흐름**:
  1. 입력된 텍스트에 대해 임의의 코드 수정/실행을 하지 않고 **학습/작업 기록 대상**으로 격리합니다.
  2. 당일 Daily 문서(`daily/YYYY-MM-DD.md`)가 없으면 `./star`를 자동 실행하여 템플릿을 생성합니다.
  3. 기술 원리(First Principles)는 `knowledge/` 문서로 자동 승격(Append-Only)하고, SSoT 원칙에 따라 Daily에는 상대 링크만 남깁니다.
- **사용법**:
  ```text
  /til Android IPC 메커니즘 분석 완료. Binder 드라이버가 공유 메모리를 활용해 데이터 복사를 1회로 줄이는 원리를 파악함.
  ```

---

### 2. `/vault` (Claude Code & Antigravity)
- **목적**: 프로젝트 아이디어 기획 또는 관심 기술(Tech Radar)을 분류 판별하여 **Idea Vault**에 기록 및 README 자동 동기화.
- **동작 흐름**:
  1. **3가지 유형 자동 판별**: Type A (프로젝트 기획), Type B (관심 기술 레이더), Type C (복합).
  2. **중복 엄격 방지**: 기존 문서를 먼저 검색하여 유사 아이디어는 기존 문서를 보강하고 `## 📝 업데이트 로그`에 이력을 누적합니다.
  3. 기술 스택은 3-Level Radar(`level-1-wishlist`, `level-2-planned`, `level-3-experienced`)에 등록/승격합니다.
  4. 완료 후 `python3 scripts/update_readme.py` 실행으로 README를 자동 동기화하고 Git 커밋/푸시합니다.
- **사용법**:
  ```text
  /vault 실시간 지하철 혼잡도 데이터를 기반으로 최적 칸을 추천해주는 React Native 앱 아이디어
  ```

---

### 3. `/commit` (Claude Code)
- **목적**: `git diff`를 분석해 원자적 커밋 단위로 쪼개어 Conventional Commits 메시지 제안.
- **사용법**:
  - `/commit` : 메시지만 추천 (기본값, 읽기 전용)
  - `/commit --commit` : 추천 단위대로 스테이징 + 커밋
  - `/commit --push` : 커밋 후 푸시까지 집행

---

### 4. `/summarize` (Claude Code)
- **목적**: 현재 세션의 작업 히스토리를 요약해 TIL에 저장하고 지식 문서로 승격.
- **사용법**: `/summarize`

---

### 5. `/new-command` (Claude Code)
- **목적**: 새로운 슬래시 커맨드를 명세 체크리스트와 게이트를 거쳐 안전하게 생성.
- **사용법**: `/new-command [목적/의도] [커맨드명]`

---

## 📁 디렉터리 구조

```
dotfiles/
├── .agents/
│   ├── skills.json          # Antigravity 스킬 레지스트리 경로
│   └── skills/              # Antigravity (AGY) 커스텀 스킬
│       ├── til/SKILL.md     # /til 스킬 명세
│       └── vault/SKILL.md   # /vault 스킬 명세
├── .claude/
│   └── commands/            # Claude Code 슬래시 커맨드
│       ├── til.md           # /til 커맨드
│       ├── vault.md         # /vault 커맨드
│       ├── commit.md        # /commit
│       ├── summarize.md     # /summarize
│       └── new-command.md   # /new-command
├── bashrc.d/                # bash 설정 프래그먼트 (01-env, 02-claude, 04-aliases)
├── zshrc.d/                 # zsh 설정 프래그먼트 (bashrc.d와 동일하게 유지)
├── bin/                     # 유틸리티 (adb 프록시 등)
├── secrets.example.sh       # 로컬 시크릿 템플릿
├── install.sh               # 원터치 설치 스크립트 (Claude Code & Antigravity 동시 지원)
└── AGENTS.md / CLAUDE.md    # AI 에이전트 운영 규칙
```

---

## ⚙️ 커스텀 슬래시 커맨드 직접 만들기

1. **Claude Code**: `~/.claude/commands/<이름>.md` 파일 생성 (프론트매터에 `description`, `allowed-tools` 정의 후 프롬프트 작성)
2. **Antigravity**: `~/.gemini/config/skills/<이름>/SKILL.md` (또는 프로젝트 `.agents/skills/<이름>/SKILL.md`) 생성
3. **동기화**: `dotfiles` 저장소에 추가 후 `install.sh` 실행 시 자동으로 심볼릭 링크가 생성되어 동기화됩니다.

---

## 🔄 업데이트

```bash
git -C ~/.dotfiles pull
```

심볼릭 링크로 연결되어 있어 `pull` 즉시 새로운 Claude Code 및 Antigravity 세션에 최신 커맨드가 자동 반영됩니다.

---

## 🔐 시크릿 처리

머신별 API 키나 토큰은 저장소에 커밋하지 않고 `~/.dotfiles.secrets.sh`에 보관합니다.

```bash
cp secrets.example.sh ~/.dotfiles.secrets.sh
chmod 600 ~/.dotfiles.secrets.sh
```

---

## 📄 라이선스

MIT License
