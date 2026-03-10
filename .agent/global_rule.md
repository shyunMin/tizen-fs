
# Agent Global Rules

## 1. Language Constraints (언어 설정)
- **Chat & Explanations:** 모든 대화 응답, 작업 진행 상황 보고, 개념 설명은 반드시 **한국어(Korean)**로 작성할 것.
- **Code Comments:** 코드 내의 모든 주석(Comments)과 문서화(Documentation)는 반드시 **영어(English)**로 작성할 것.
- **Git & GitHub:** 커밋 메시지(Commit messages), 브랜치 이름, PR(Pull Request) 제목 및 본문은 반드시 **영어(English)**로 작성할 것.

## 2. Security & Code Quality (보안 및 코드 품질)
- **API Key Protection:** 코드를 수정하거나 커밋하기 전, 하드코딩된 API 키, 토큰, 비밀번호 등 민감한 정보가 있는지 반드시 스캔하고 제거할 것.
- 필요한 경우 환경 변수(`.env`) 파일로 분리하도록 코드를 수정하고, 해당 파일이 `.gitignore`에 포함되어 있는지 확인할 것.

## 3. Git & GitHub Workflow (Git 작업 흐름)
- 코드 수정 후 원격 저장소에 반영할 때 다음 프로세스를 따를 것:
  1. 새로운 기능이나 수정 사항에 맞는 새 브랜치를 생성 (`git checkout -b <branch_name>`)
  2. 작업 내역을 커밋 (`git commit -m "<Clear description in English>"`)
  3. 수정된 내용을 `shyun` 원격 저장소로 푸시 (`git push shyun <branch_name>`)
  4. GitHub CLI를 사용하여 PR 생성 (`gh pr create --title "<Title>" --body "<Body>"`)