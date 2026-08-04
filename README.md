# dotfiles — Claude Code 슬래시 커맨드까지 동기화하는 dotfiles

WSL2 + tmux + React Native / Android 환경의 셸 설정과, **Claude Code 커스텀 슬래시
커맨드**를 한 저장소에서 관리합니다. 새 기기를 세팅할 때 `.zshrc`뿐 아니라
`/commit`, `/summarize` 같은 슬래시 커맨드까지 한 번에 따라옵니다.

---

## ⚡ 원터치 설치

**슬래시 커맨드 전체를 한 번에 설치** — 이 한 줄이면 끝입니다.

```bash
curl -fsSL https://raw.githubusercontent.com/Hanzi-Cho/dotfiles/main/install.sh | bash -s -- --commands-only
```

`~/.dotfiles`에 저장소를 클론하고 `~/.claude/commands/`로 심볼릭 링크를 걸어줍니다.
이후 `git -C ~/.dotfiles pull`만 하면 커맨드가 자동으로 최신화됩니다.

셸 설정(`bashrc.d`, `zshrc.d`, `bin/`)까지 포함한 **전체 설치**는 이쪽입니다.

```bash
git clone https://github.com/Hanzi-Cho/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
```

<details>
<summary>설치 옵션</summary>

| 옵션 | 동작 |
|---|---|
| (없음) | 셸 프래그먼트 + 슬래시 커맨드 전체 설치 |
| `--commands-only` | 슬래시 커맨드만 설치 (셸 설정 건드리지 않음) |
| `--copy` | 심볼릭 링크 대신 복사 (자동 업데이트 안 됨) |
| `--dry-run` | 무엇을 할지만 출력하고 아무것도 바꾸지 않음 |

먼저 `--dry-run`으로 확인하는 걸 권합니다. 기존에 같은 이름의 실제 파일이 있으면
`*.bak`으로 백업한 뒤 링크를 겁니다.

</details>

---

## 📦 My Claude Skills

각 커맨드는 독립적입니다. 필요한 것만 골라 한 줄로 설치할 수 있습니다.

### /new-command

의도와 이름만 주면 **새 슬래시 커맨드를 설계·생성해주는 커맨드**. 이름 충돌 검사와
명세 체크리스트를 게이트로 두고, 미리보기 승인 후에만 파일을 씁니다.

```bash
curl -fsSL https://raw.githubusercontent.com/Hanzi-Cho/dotfiles/main/.claude/commands/new-command.md -o ~/.claude/commands/new-command.md
```

### /commit

`git diff`를 **원자적 커밋 단위로 쪼개** Conventional Commits 메시지만 출력합니다.
읽기 전용 — 실제로 스테이징하거나 커밋하지 않습니다.

```bash
curl -fsSL https://raw.githubusercontent.com/Hanzi-Cho/dotfiles/main/.claude/commands/commit.md -o ~/.claude/commands/commit.md
```

### /summarize

현재 세션을 **TIL Daily(STAR) 문서에 병합**하고, 기술 학습은 `knowledge/`로 승격한 뒤
승인을 받아 커밋·푸시까지 합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/Hanzi-Cho/dotfiles/main/.claude/commands/summarize.md -o ~/.claude/commands/summarize.md
```

> ⚠️ `/summarize`는 쓰기 전에 **CONFIG 블록의 `TIL_ROOT`, `GIT_USER_NAME`,
> `GIT_USER_EMAIL`을 본인 값으로 고쳐야** 합니다. 기본값(`$HOME/til`)이 없으면
> 커맨드가 중단됩니다.

디렉터리가 없다면 먼저 `mkdir -p ~/.claude/commands`를 실행하세요.

---

## 🛠 슬래시 커맨드 직접 만들기 — STEP별 가이드

슬래시 커맨드는 **`~/.claude/commands/` 안의 마크다운 파일 한 개**가 전부입니다.
파일명이 곧 커맨드 이름이 됩니다 (`deploy-check.md` → `/deploy-check`).

### STEP 1. 파일 위치와 스코프 정하기

| 스코프 | 경로 | 쓰임 |
|---|---|---|
| 개인 (전역) | `~/.claude/commands/<이름>.md` | 모든 프로젝트에서 사용. dotfiles로 동기화할 대상 |
| 프로젝트 | `<repo>/.claude/commands/<이름>.md` | 팀과 공유. 저장소에 함께 커밋 |

```bash
mkdir -p ~/.claude/commands
```

이름은 kebab-case 소문자로, 목적이 드러나게 짓습니다. 빌트인 커맨드
(`clear`, `help`, `review`, `commit`, `config`, `init`, `model`, `compact` 등)와
겹치면 덮어써지므로 먼저 `ls ~/.claude/commands/`로 확인하세요.

### STEP 2. 프론트매터 작성

파일 맨 위 YAML 블록이 커맨드의 메타데이터입니다.

```markdown
---
description: git diff를 원자적 커밋 단위로 분리해 메시지만 출력
argument-hint: "[프로젝트 경로 또는 이름 (생략 가능)]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Read, Grep
model: inherit
---
```

| 키 | 역할 |
|---|---|
| `description` | `/help` 목록에 뜨는 한 줄 설명. **필수에 가깝습니다** |
| `argument-hint` | 입력 중 표시되는 인자 힌트 |
| `allowed-tools` | 이 커맨드가 쓸 수 있는 도구. **최소 권한으로 좁히세요** |
| `model` | `opus` / `sonnet` / `haiku` / `inherit` |

`allowed-tools`가 핵심입니다. `Bash(git diff:*)`처럼 명령 단위로 좁히면 매번 권한을
묻지 않고, 동시에 커맨드가 할 수 있는 일의 상한이 생깁니다. 읽기 전용 커맨드라면
쓰기 도구(`Write`, `Edit`)를 아예 넣지 마세요.

### STEP 3. 본문 = 프롬프트 작성

프론트매터 아래 마크다운 전체가 Claude에게 전달되는 프롬프트입니다. 잘 동작하는
커맨드는 대체로 이 4가지를 갖고 있습니다.

1. **역할과 목표** — "너는 ~로 동작한다. 목표는 ~다"
2. **STEP별 절차** — 단계를 번호로 쪼개고, 각 단계의 완료 조건을 명시
3. **출력 포맷** — 예시를 그대로 보여주는 게 가장 효과적입니다
4. **금지 사항** — 하지 말아야 할 것을 명시 (예: "실제로 커밋하지 마라")

### STEP 4. 인자와 동적 컨텍스트 넣기

| 문법 | 의미 |
|---|---|
| `$ARGUMENTS` | 커맨드에 넘긴 인자 전체 |
| `$1`, `$2` | 위치 인자 |
| <code>!\`명령\`</code> | **커맨드 실행 시점에** bash를 돌려 그 출력을 프롬프트에 삽입 |
| `@경로` | 해당 파일 내용을 프롬프트에 삽입 |

```markdown
현재 변경: !`git status --short`
대상 파일: @src/index.ts
사용자 인자: $ARGUMENTS
```

<code>!\`\`</code> 안의 명령은 `allowed-tools`에 허용돼 있어야 실행됩니다.

### STEP 5. 게이트를 넣어 안전하게 만들기

파일을 쓰거나 커밋하는 커맨드라면, **실행 전에 멈춰서 승인을 받는 단계**를 반드시
넣으세요. 이게 없으면 의도와 다른 결과를 되돌리기 어렵습니다.

```markdown
## STEP 3 — 미리보기 (게이트)

생성할 파일 전문을 코드블록으로 보여주고 `이대로 생성할까요? (yes / 수정요청)`만
묻는다. yes 이전에는 쓰지 않는다.
```

### STEP 6. 적용하고 테스트

```bash
ls ~/.claude/commands/          # 파일이 있는지
```

최신 Claude Code는 새 커맨드를 자동으로 인식합니다. `/`를 입력해 목록에 뜨는지
확인하세요. 안 보이면 세션을 새로 열면 적용됩니다.

> 슬래시 커맨드는 자기 CLI를 재시작할 수 없습니다. 재시작은 사용자가 직접 해야 합니다.

### STEP 7. dotfiles로 동기화

동작을 확인했으면 저장소로 옮기고 링크로 바꿉니다. 이제 `git pull`만으로
모든 기기에 반영됩니다.

```bash
mv ~/.claude/commands/my-command.md ~/.dotfiles/.claude/commands/
ln -sfn ~/.dotfiles/.claude/commands/my-command.md ~/.claude/commands/my-command.md
git -C ~/.dotfiles add .claude/commands/my-command.md
git -C ~/.dotfiles commit -m "feat(commands): /my-command 추가"
```

`install.sh`는 이 링크 작업을 모든 커맨드에 대해 자동으로 해줍니다.

> **팁:** 위 STEP 1~6을 대신 해주는 게 `/new-command`입니다. 직접 쓰기 전에
> `/new-command`로 초안을 만들고 다듬는 쪽이 빠릅니다.

---

## 📁 디렉터리 구조

```
dotfiles/
├── .claude/
│   └── commands/            # Claude Code 슬래시 커맨드
│       ├── new-command.md   # /new-command
│       ├── commit.md        # /commit
│       └── summarize.md     # /summarize
├── bashrc.d/                # bash 프래그먼트 (번호 순서대로 source)
│   ├── 01-env.sh            # PATH, NVM, JDK, Android SDK
│   ├── 02-claude.sh         # Claude Code 계정 전환기
│   └── 04-aliases.sh        # 별칭, devlog 헬퍼
├── zshrc.d/                 # zsh 프래그먼트 (bashrc.d와 동일하게 유지)
├── bin/
│   └── adb                  # WSL → Windows adb.exe 프록시
├── secrets.example.sh       # 로컬 설정 템플릿 (실제 값은 여기 넣지 않음)
├── CLAUDE.md                # 이 저장소에서 Claude에게 주는 규칙
└── install.sh               # 설치 스크립트
```

---

## 🔐 시크릿 처리

**이 저장소에는 실제 키·토큰·개인 경로를 넣지 않습니다.** 머신별 값은 저장소 밖
`~/.dotfiles.secrets.sh`에 두고, 셸 로더가 프래그먼트보다 **먼저** 이 파일을
source합니다.

```bash
cp secrets.example.sh ~/.dotfiles.secrets.sh
chmod 600 ~/.dotfiles.secrets.sh
$EDITOR ~/.dotfiles.secrets.sh
```

`secrets.example.sh`가 프래그먼트들이 읽는 변수 전체를 문서화합니다
(`GOOGLE_API_KEY`, `SSL_CERT_FILE`, `ANDROID_HOME`, `CLAUDE_WIN_HOME`,
`CURSOR_BIN`, `DEVLOG_DIR` 등). 새 변수를 쓸 때는 여기에 **주석 처리된
플레이스홀더로만** 추가하세요.

`.gitignore`가 `*.secrets.sh`, `*.pem`, `*.key`, `.credentials.json`을 막아두었지만
2차 방어선일 뿐입니다. 커밋 전에 한 번 훑어보세요.

```bash
git diff --cached | grep -iE 'api[_-]?key|token|secret|password|AIza|ghp_'
```

---

## 🔄 업데이트

```bash
git -C ~/.dotfiles pull
```

심볼릭 링크로 설치했다면 슬래시 커맨드는 즉시 반영됩니다. 셸 프래그먼트를 고쳤다면
새 셸을 열거나 `source ~/.bashrc`를 실행하세요.

---

## 라이선스

MIT
