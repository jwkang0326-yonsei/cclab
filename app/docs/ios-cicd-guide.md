# iOS CI/CD 설정 가이드 (Fastlane + GitHub Actions)

이 문서는 '위드바이블' iOS 앱의 자동 배포(TestFlight 업로드)를 위한 설정 방법과 운영 가이드를 담고 있습니다.

## 1. 개요
*   **도구**: GitHub Actions, Fastlane
*   **목표**: `main` 브랜치 푸시 또는 수동 트리거 시 자동으로 TestFlight에 앱 업로드.
*   **인증서 관리**: Fastlane Match 사용 (Private Git 저장소 활용).

## 2. 필수 사전 준비 (Prerequisites)

### 2.1 Apple 개발자 계정
*   App Store Connect에 접속 권한이 있는 계정.
*   **API Key 생성**: [App Store Connect](https://appstoreconnect.apple.com/) > 사용자 및 액세스 > 키 > App Store Connect API에서 키 생성 (.p8 파일).

### 2.2 인증서 저장소 (Certificate Repo)
*   iOS 인증서와 프로비저닝 프로필을 암호화하여 저장할 **Private Git Repository**를 하나 생성하세요. (예: `cclab-ios-certs`)
*   이 저장소는 아무도 접근하지 못하도록 **Private**으로 설정해야 합니다.

## 3. GitHub Secrets 설정 (중요!)

GitHub 저장소의 `Settings` > `Secrets and variables` > `Actions` > `New repository secret`에서 다음 값들을 등록해야 빌드가 성공합니다.

| Secret 이름 | 설명 | 예시/형식 |
| :--- | :--- | :--- |
| `MATCH_PASSWORD` | 인증서 저장소 암호화/복호화에 사용할 비밀번호 | `my_strong_password` |
| `MATCH_GIT_BASIC_AUTHORIZATION` | 인증서 Git 저장소 접근 토큰 (Base64 인코딩) | `dXNlcm...` (터미널에서 `echo -n 'user:ghp_token' | base64` 로 생성) |
| `APP_STORE_CONNECT_API_KEY_KEY` | App Store Connect API Key (.p8) 파일 내용 전체 | `-----BEGIN PRIVATE KEY-----...` |
| `APP_STORE_CONNECT_API_KEY_KEY_ID` | API Key의 Key ID | `ABC1234567` |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | API Key의 Issuer ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |

## 4. 로컬 설정 파일 수정 (Local Config)

다음 파일들의 `TODO` 항목을 실제 값으로 채워넣어야 합니다.

1.  **`app/ios/fastlane/Appfile`**:
    *   `apple_id`: 본인의 Apple ID 이메일 주소 입력.
2.  **`app/ios/fastlane/Matchfile`**:
    *   `git_url`: 2.2에서 생성한 인증서 저장소의 URL 입력.

## 5. 인증서 최초 생성 (First Run)

로컬 터미널에서 다음 명령어를 실행하여 인증서를 생성하고 저장소에 업로드합니다.

```bash
cd app/ios
bundle install
bundle exec fastlane match appstore
```

*   이때 입력하는 비밀번호가 `MATCH_PASSWORD`가 됩니다.

## 6. 트러블슈팅 (Troubleshooting)

*   **인증서 오류**: `fastlane match nuke` 명령어로 인증서를 초기화하고 다시 생성해보세요. (주의: 기존 인증서 무효화됨)
*   **2FA 인증 요청**: 로컬에서 실행 시 2FA 코드를 요구할 수 있습니다. CI에서는 API Key를 사용하므로 발생하지 않아야 합니다.
*   **버전 번호 충돌**: `pubspec.yaml`의 버전(`version: 1.0.0+1`)을 올려서 푸시하세요. TestFlight는 같은 빌드 번호를 허용하지 않습니다.
