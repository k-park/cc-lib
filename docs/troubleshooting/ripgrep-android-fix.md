# Claude Code Ripgrep 오류 해결 (Android/Termux)

## 문제

Claude Code에서 Grep 도구 사용 시 다음 오류 발생:

```
spawn /data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-android/rg ENOENT
```

## 원인

Claude Code가 플랫폼을 `arm64-android`로 감지하지만, 번들된 ripgrep 바이너리는 다음 플랫폼만 지원:
- `arm64-linux`
- `arm64-darwin`
- `x64-linux`
- `x64-darwin`
- `x64-win32`

`arm64-android` 디렉토리가 존재하지 않음.

## 해결 방법

`arm64-linux` 바이너리를 `arm64-android`로 심볼릭 링크 생성 (Android는 Linux 커널 기반이므로 호환됨):

```bash
cd /data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/
ln -s arm64-linux arm64-android
```

## 확인

```bash
ls -la /data/data/com.termux/files/usr/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/
```

결과:
```
arm64-android -> arm64-linux
```

## 주의사항

- Claude Code 업데이트 시 심볼릭 링크가 삭제되므로 재적용 필요
- 업데이트 후 Grep 도구 오류 발생 시 위 명령어 다시 실행

## 적용 날짜

2026-01-12
