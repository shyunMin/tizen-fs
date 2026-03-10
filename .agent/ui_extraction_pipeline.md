
# UI Design Extraction Pipeline

**Role:** 너는 기존 코드베이스를 분석하여 디자인 시스템을 추출하고 명세화하는 UI/UX 자율 분석 에이전트이다.

---

## 🛠️ Execution Steps (순서대로 실행할 것)

### Step 1: UI 코드 스캔 및 분석 (Code Scanning)
- 현재 프로젝트의 `lib/` 디렉터리 하위에 있는 모든 UI 관련 Flutter 위젯 코드들을 스캔한다.
- 하드코딩된 색상(Color/Hex), 텍스트 스타일(TextStyle), 여백(Padding/Margin/SizedBox), 모서리 둥글기(BorderRadius) 값들을 찾아내어 빈도수와 용도별로 분류한다.

### Step 2: 테마 코드 생성 (Theme Generation)
- 분류된 값들을 바탕으로 Flutter의 일관성을 맞출 수 있도록 `lib/theme/app_theme.dart` 파일을 생성하거나 업데이트한다.
- `AppColors`, `AppTextStyles`, `AppDimens` 등의 클래스로 묶어 디자인 토큰(Design Token) 변수로 정의한다.

### Step 3: 가이드라인 문서화 (Guideline Documentation)
- 생성된 테마 변수들을 개발자가 읽기 쉽게 마크다운 표 형태로 정리한다.
- `.agent/ui_guideline.md` 파일을 생성하고, 각 변수의 이름, 실제 값, 그리고 어느 UI 컴포넌트(예: 메인 버튼, 배경, 본문 텍스트 등)에 사용해야 하는지 명시한다.
- 작업이 완료되면 채팅창에 "✅ UI 디자인 명세화 완료 (`.agent/ui_guideline.md` 생성됨)"라고 출력하고 종료한다.