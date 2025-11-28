# 2D 캐릭터 애니메이션 추가 가이드

## 방법 1: Lottie 사용 (추천 - 가장 쉬움)

### 1. Lottie 애니메이션 파일 다운로드
1. [LottieFiles](https://lottiefiles.com) 방문
2. 무료 계정 생성 (선택사항)
3. "Free" 카테고리에서 원하는 캐릭터 애니메이션 검색
   - 예: "character", "idle", "walking", "celebration" 등
4. JSON 파일 다운로드

### 2. 프로젝트에 파일 추가
1. 프로젝트 루트에 `assets/animations/` 폴더 생성
2. 다운로드한 JSON 파일을 해당 폴더에 복사
   - 예: `assets/animations/character_idle.json`
   - 예: `assets/animations/character_celebration.json`

### 3. pubspec.yaml 설정
```yaml
flutter:
  assets:
    - assets/animations/
```

### 4. 코드에서 사용
`lib/screens/character_screen.dart` 파일의 `_buildCharacterAnimation()` 메서드에서 주석을 해제하고 사용:

```dart
Widget _buildCharacterAnimation() {
  if (_currentAnimation == 'idle') {
    return Lottie.asset(
      'assets/animations/character_idle.json',
      controller: _idleController,
      onLoaded: (composition) {
        _idleController
          ..duration = composition.duration
          ..repeat();
      },
    );
  } else {
    return Lottie.asset(
      'assets/animations/character_celebration.json',
      controller: _celebrationController,
      onLoaded: (composition) {
        _celebrationController
          ..duration = composition.duration
          ..repeat();
      },
    );
  }
}
```

---

## 방법 2: Rive 사용 (인터랙티브 애니메이션)

### 1. Rive 애니메이션 생성
1. [Rive](https://rive.app) 방문
2. 무료 계정 생성
3. 온라인 에디터에서 캐릭터 애니메이션 제작 또는 템플릿 사용
4. `.riv` 파일로 내보내기

### 2. 패키지 추가
```yaml
dependencies:
  rive: ^0.12.0
```

### 3. 사용 예시
```dart
import 'package:rive/rive.dart';

RiveAnimation.asset('assets/animations/character.riv')
```

---

## 방법 3: Sprite Sheet 사용

여러 이미지를 순차적으로 재생하는 방법입니다.

### 1. Sprite Sheet 이미지 준비
- 캐릭터의 각 프레임을 이미지로 준비
- 예: `character_frame_1.png`, `character_frame_2.png`, ...

### 2. 패키지 추가
```yaml
dependencies:
  spritewidget: ^0.9.0
```

---

## 추천 무료 Lottie 애니메이션 사이트

1. **LottieFiles** (https://lottiefiles.com)
   - 가장 많은 무료 애니메이션
   - 검색: "character idle", "character walk", "celebration"

2. **IconScout** (https://iconscout.com/lottie-animations)
   - 고품질 애니메이션

3. **Lordicon** (https://lordicon.com)
   - 아이콘 스타일 애니메이션

---

## 빠른 시작 (Lottie)

1. LottieFiles에서 "character idle" 검색
2. 마음에 드는 애니메이션 선택
3. "Download" → "Lottie JSON" 선택
4. 파일을 `assets/animations/character_idle.json`에 저장
5. `pubspec.yaml`에 assets 경로 추가
6. `character_screen.dart`의 주석 해제
7. `flutter pub get` 실행
8. 앱 재시작

