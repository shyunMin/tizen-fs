# UI Design Guideline

이 문서는 기존 코드베이스를 분석하여 추출한 하드코딩된 UI 디자인 값들을 명세화한 것입니다.
앞으로 추가되는 UI 컴포넌트(위젯)는 반드시 이 가이드라인(및 `lib/theme/app_theme.dart`)에 명시된 디자인 토큰을 사용하여 구현해야 합니다.

## 🎨 색상 토큰 (AppColors)

| 변수명 | 실제 색상값 (`Color`) | 용도 / 적용 컴포넌트 |
|---|---|---|
| `focus` | `Color(0xF04285F4)` | 포커스(선택)된 아이템의 텍스트, 아이콘, 버튼 등 활성화 상태 강조 색상 |
| `textSecondary` | `Color(0xFF979AA0)` | 서브타이틀, 부가 설명 등 덜 강조되는 부차적 텍스트 색상 |
| `iconInactive` | `Color(0xF0AEB2B9)` | 포커스되지 않은 아이콘 및 비활성화된 요소 색상 |
| `unfocusedBackground` | `Color(0xF0263041)` | 포커스되지 않은 리스트 아이템 등의 배경 색상 |
| `darkBackground` | `Color(0xFF101010)` | 팝업 내 특정 배경이나 매우 어두운 컨테이너 색상 |

## 📐 여백 토큰 (AppDimens)

| 변수명 | 실제 값 | 용도 / 적용 컴포넌트 |
|---|---|---|
| `pagePaddingLarge` | `EdgeInsets.fromLTRB(120, 60, 40, 0)` | 메인 페이지의 전체 여백 (화면 비율/상태에 따라 사용됨) |
| `pagePaddingNormal` | `EdgeInsets.fromLTRB(80, 60, 80, 0)` | 메인 페이지의 일반적인 전체 여백 |
| `paddingHorizontalLarge` | `80.0` | 카드, 리스트, 페이지 내 넓은 좌우 여백 |
| `paddingHorizontalNormal` | `40.0` | 일반적인 컴포넌트 내부 좌우 여백 |
| `popupPadding` | `EdgeInsets.fromLTRB(80, 80, 0, 0)` | 팝업창 바깥/컨테이너 상단 여백 |
| `popupContentPadding` | `EdgeInsets.fromLTRB(0, 100, 0, 0)` | 팝업창 내 주요 콘텐츠 상단 여백 |

## 🟢 둥글기 토큰 (BorderRadius)

| 변수명 | 실제 값 | 용도 / 적용 컴포넌트 |
|---|---|---|
| `borderRadiusNormal` | `10.0` | 일반적인 리스트 아이템, 미디어 카드 모서리 반경 |
| `borderRadiusLarge` | `20.0` | 중간 크기 팝업, 알림 패널 등의 모서리 반경 |
| `borderRadiusXLarge`| `30.0` | 대형 팝업 또는 라운드 버튼 모서리 반경 |
| `borderRadiusSmall` | `8.0` | 작은 입력창(TextField) 및 보조 버튼 모서리 반경 |

## 🔠 텍스트 스타일 (AppTextStyles)

| 변수명 | 스타일 (`TextStyle`) | 용도 / 적용 컴포넌트 |
|---|---|---|
| `secondaryText` | `fontSize: 11, color: textSecondary` | 서브타이틀 텍스트, 추가 설명 및 멘트 |

---
*참고: `lib/theme/app_theme.dart` 파일에 위 토큰들이 정의되어 있으므로, UI 구현 시 `AppTheme.colors.focus` 와 같이 접근하여 사용할 것.*
