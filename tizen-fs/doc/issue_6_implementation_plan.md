# Issue #6 Implementation Plan

## 1. 개요 (Overview)
- 설정(Settings) 메뉴에 Wi-Fi 외에 **유선 연결(Ethernet)** 항목을 추가합니다.
- 사용자가 유선 네트워크 연결 시 고정 IP(Static IP) 모드를 사용하기 위해 필요한 IP, Gateway, Subnet 마스크, DNS 값을 입력할 수 있는 UI를 제공합니다.

## 2. 세부 작업 내역 (Tasks)

### 2.1 신규 UI 구현 (`EthernetPage`)
- **경로**: `lib/settings/ethernet_page.dart` (신규 생성)
- **주요 기능**:
  - `TextField`를 사용하여 IP 주소, 서브넷 마스크, 게이트웨이, DNS를 각각 입력받음.
  - Tizen 디바이스 (TV/리모컨) 특성을 고려해 각 `TextField`와 **저장(Save)/연결(Connect)** 버튼 간 `FocusNode` 이동이 원활하도록 `onKeyEvent` 설계.
  - 사용자가 입력한 문자열을 바탕으로 IPv4 형식 유효성(Validation) 간단 처리.

### 2.2 메뉴 등록 (`SettingsMenus`)
- **경로**: `lib/models/settings_menus.dart`
- **주요 기능**:
  - `settings.children.add(...)` 항목 중 `wifi` 아래쪽에 `ethernet` 노드 추가.
  - 아이콘: `Icons.settings_ethernet`
  - 제목(title): `'ethernet'` (다국어 리소스 활용)
  - `builder` 를 통해 새로 생성한 `EthernetPage` 로 연결.

### 2.3 다국어 텍스트(L10N) 재사용 및 추가
- `lib/l10n/app_localizations_*.dart` 파일들에서 이미 존재하는 키(`ipAddress`, `subnetMask`, `gateway`, `ethernet`)를 최대한 재사용하고, 부족한 문자열(예: `dns`, `save` 등)이 리소스에 없으면 직접 하드코딩 또는 L10n에 추가.

### 2.4 검증 (Verification Plan)
- **정적 분석**: `flutter analyze` 명령이 정상적으로 0건 통과하는지 확인. (또는 IDE의 Dart analyzer 오류 여부 체크)
- **빌드 테스트**: `flutter-tizen build tpk` 등의 유효한 빌드 명령이 오류 없이 수행되는지 확인.
- UI상 문법 및 렌더 트리 에러가 없는지 위젯 파일 내부 로직 체크.
