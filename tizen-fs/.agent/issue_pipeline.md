# 🚀 Antigravity Autonomous Issue Resolution Pipeline

**Role:** 너는 주어진 GitHub 이슈를 처음부터 끝까지 스스로 분석, 계획, 구현, 검증, PR 생성까지 수행하는 자율 개발 에이전트이다.

**Input:** 사용자가 채팅창에 제공한 `ISSUE_NUMBER`

---

## 🛠️ Execution Steps (순서대로 실행할 것)

### Step 1: 이슈 분석 (Issue Analysis)
- 터미널에서 `gh issue view https://github.com/shyunMin/tizen-fs/issues/<ISSUE_NUMBER>` 명령어를 실행한다.
- 출력된 본문과 요구사항을 꼼꼼히 읽고 목표를 파악한다.

### Step 2: 구현 계획 문서화 (Documentation & Diagramming)
- 파악한 요구사항을 바탕으로 변경할 아키텍처와 수정할 파일 목록을 정리한다.
- 구현 계획 문서 내에 **Mermaid 클래스 다이어그램**을 반드시 포함시키며, 다음 색상 규칙을 적용한다:
  - 🟩 **새로 추가될 클래스:** `fill:#d4edda, stroke:#28a745`
  - 🟨 **수정될 기존 클래스:** `fill:#fff3cd, stroke:#ffc107`
  - ⬜ **유지될 연관 클래스:** 기본 색상
- `doc/` 디렉터리에 `issue_<ISSUE_NUMBER>_implementation_plan.md` 파일을 만들고, 내용은 **한국어**로 작성한다.

### Step 3: 코드 구현 및 빌드 검증 (Implementation & Build)
- 작성한 계획서에 따라 실제 코드를 수정한다. (코드 주석은 영어로 작성)
- **[중요] Device API 연동 규칙:** 실제 디바이스를 조작하는 서비스나 Provider를 구현할 때는 반드시 **인터페이스(Interface)를 먼저 정의**하고 이를 상속받아 구현체를 작성한다.
- 실제 Tizen Device API 호출이나 하드웨어 제어가 들어가야 하는 빈 공간(메서드 내부 등)에는 반드시 `// TODO: [Device API] <설명>` 형태의 영어 주석을 명확히 남겨둔다.
- 코드 작성이 끝나면 프로젝트 환경(Ubuntu/Tizen)에 맞는 빌드 명령어를 터미널에서 실행해 정상 동작을 확인한다. 에러 발생 시 스스로 수정하고 다시 빌드한다.

### Step 4: 사용자 컨펌 대기 (Wait for User Approval)
- 빌드가 성공하면 터미널 실행을 멈추고 채팅창에 다음 메시지를 출력하며 대기한다:
  > "✅ 구현 및 빌드가 완료되었습니다. 원격 저장소에 Push하고 PR을 생성할까요?"
- 사용자가 명시적으로 승인하기 전까지는 절대 다음 단계로 넘어가지 않는다.

### Step 5: PR 생성 및 이슈 연결 (Pull Request)
- 사용자의 승인이 떨어지면, 다음 순서로 Git 명령어를 실행한다:
  1. `git checkout -b feature/issue-<ISSUE_NUMBER>`
  2. `git add .`
  3. `git commit -m "Resolve issue <ISSUE_NUMBER>: [영문 핵심 요약]"`
  4. `git push shyun feature/issue-<ISSUE_NUMBER>`
- **PR 생성 (`gh pr create`):** PR의 본문(`--body`)을 작성할 때, 이번 작업의 전반적인 요약과 함께 **Step 3에서 작성했던 `// TODO: [Device API]` 항목들을 찾아 리스트업**하고, 어떤 실제 디바이스 API 연동이 추가로 필요한지 구체적인 설명을 포함하여 작성한다. (PR 본문은 영어로 작성하며, 마지막에 `Resolves #<ISSUE_NUMBER>`를 포함한다.)