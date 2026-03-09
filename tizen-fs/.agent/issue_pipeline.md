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
- 구현 계획 문서 내에 **Mermaid 클래스 다이어그램**을 반드시 포함시켜야 하며, 다음 색상 규칙(`classDef` 또는 `style` 사용)을 엄격히 적용해 시각적으로 구분한다:
  - **새로 추가될 클래스:** 녹색 계열 (예: `fill:#d4edda, stroke:#28a745`)
  - **변경이 필요한 기존 클래스:** 노란색/주황색 계열 (예: `fill:#fff3cd, stroke:#ffc107`)
  - **변경이 없는 연관 클래스:** 기본 색상 유지
- 다이어그램에는 해당 클래스들의 의존성 및 관계(화살표)도 명확히 표시한다.
- `doc/` 디렉터리가 없다면 생성하고, `doc/issue_<ISSUE_NUMBER>_implementation_plan.md` 파일을 만든다.
- 파일 내용(계획서)은 사용자가 읽기 편하도록 **한국어**로 상세히 작성한다.

### Step 3: 코드 구현 및 빌드 검증 (Implementation & Build)
- 작성한 계획서에 따라 실제 코드를 수정한다. (코드 주석은 영어로 작성)
- 수정이 끝나면 프로젝트 환경(Ubuntu/Tizen)에 맞는 빌드 명령어를 터미널에서 실행해 정상 동작을 확인한다.
- **Self-Correction:** 빌드 에러가 발생하면 스스로 에러 로그를 분석하고 코드를 수정한 뒤 다시 빌드한다. 이 과정을 성공할 때까지 반복한다.

### Step 4: 사용자 컨펌 대기 (Wait for User Approval)
- 빌드가 완벽하게 성공하면, 터미널 실행을 멈추고 채팅창에 다음 메시지를 출력하며 대기한다:
  > "✅ 구현 및 빌드 검증이 완료되었습니다. 변경된 코드와 다이어그램을 확인해 주세요. 원격 저장소에 Push하고 PR을 생성할까요?"
- 사용자가 "진행해", "ok", "승인" 등의 긍정적인 답변을 주기 전까지는 **절대** 다음 단계의 Git 명령어(`push`, `pr create`)를 실행하지 않는다.

### Step 5: PR 생성 및 이슈 연결 (Pull Request)
사용자의 승인이 떨어지면, 터미널에서 다음 순서로 Git 명령어를 실행한다:
1. `git checkout -b feature/issue-<ISSUE_NUMBER>`
2. `git add .`
3. `git commit -m "Resolve issue <ISSUE_NUMBER>: [영문 핵심 요약]"`
4. `git push shyun feature/issue-<ISSUE_NUMBER>`
5. `gh pr create --title "[Feature/Fix] Resolve issue <ISSUE_NUMBER>" --body "This PR follows the implementation plan in the doc folder. Resolves #<ISSUE_NUMBER>"`