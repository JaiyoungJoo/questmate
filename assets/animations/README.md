# 애니메이션 파일 저장 위치

이 폴더에는 2D 캐릭터 애니메이션 파일을 넣습니다.

## 스프라이트 시트 사용하기

1. 8프레임 이상으로 구성된 스프라이트 시트를 준비합니다.
2. 파일 이름을 `character_sprite.png` 로 맞춰서 이 폴더에 복사합니다.
   - 다른 이름을 쓰고 싶다면 `lib/screens/character_screen.dart` 상단의 `_idleSpritePath`, `_celebrationSpritePath` 값을 수정하세요.
3. 기본값으로는 프레임 크기를 자동으로 계산합니다. (스프라이트 전체 폭 ÷ 프레임 수, 전체 높이)
   - 필요하면 `character_screen.dart` 의 `_frameWidth`, `_frameHeight` 값을 직접 설정하세요.
4. 프레임 수가 8이 아니라면 `_frameCount` 값을 변경하세요.

## Lottie 애니메이션 사용하기

1. [LottieFiles](https://lottiefiles.com)에서 원하는 캐릭터 애니메이션을 다운로드합니다.
2. JSON 파일을 이 폴더에 복사합니다. (예: `character_idle.json`)
3. `LOTTIE_SETUP.md` 문서를 참고해 코드를 Lottie 버전으로 전환하세요.

## 추천 키워드

- "character sprite"
- "pixel hero"
- "character idle"
- "character walk"
- "character celebration"

