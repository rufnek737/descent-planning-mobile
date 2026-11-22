# Claude 작업 규칙

## "오늘 마무리 하자" = 세션 마무리 절차

사용자가 "오늘 마무리 하자"(또는 비슷한 말: "오늘 마무리", "마무리하자")라고 하면 아래를 순서대로 한다. 따로 다시 묻지 않는다.

1. 이번 세션에서 바뀐 내용을 확인한다 (`git status`, `git diff`, 이번 세션의 커밋).
2. `README.md`의 `## 변경 기록` 섹션 **맨 위**에 오늘 날짜 항목을 추가한다.
   - 형식: `### YYYY-MM-DD` 아래에 한 줄씩 짧게 (무엇을 바꿨는지, 결정한 것, 다음에 할 일)
   - 코드 변경이 없고 확인·결정만 했어도 그 내용을 적는다.
   - README 위쪽 `## 현재 상태`가 달라졌으면(버전, 스토어 상태 등) 같이 고친다.
3. 변경을 두 종류로 나눠서 올린다.
   - **문서만 바뀐 경우** (`README.md`, `CLAUDE.md`, `WORK_LOG.md` 등 `.md` 문서): 커밋 메시지 `docs: README 변경 기록 YYYY-MM-DD`로 커밋하고 **`main`에 바로 push**한다 (사용자가 미리 허락함). 작업 브랜치도 같은 커밋으로 맞춰 push한다.
   - **앱 코드 변경이 있는 경우** (`www/`, `android/`, `ios/`, `package.json`, `capacitor.config.json`, `assets/`, `icons/`, `.github/` 등 문서 외 전부):
     1. 코드 변경은 현재 작업 브랜치에 커밋하고 push한다 (`git push -u origin <현재 브랜치>`).
     2. 그 브랜치에서 `main`으로 가는 **PR을 만든다** (GitHub MCP `create_pull_request`, PR 템플릿이 있으면 따른다). 병합은 하지 않는다. 사용자가 확인 후 병합한다.
     3. README 변경 기록은 코드와 분리해서 `main` 위에 별도 커밋으로 올리고 바로 push한다. 기록에 PR 링크를 적는다.
   - `main`에 코드 변경을 직접 push하지 않는다. `main` push가 fast-forward가 안 되면 `git fetch origin main` 후 그 위에서 다시 커밋한다 (force push 금지).
4. 무엇을 적었는지, `main`에 올린 것과 PR로 남긴 것을 짧게 보고한다.

## 기타
- 사용자는 폰(클라우드 세션)에서 작업하는 경우가 많다. 답변은 짧고 한국어로 쓴다.
- 스토어 업로드·공개는 항상 사용자 허락 후, App Store와 Google Play를 같은 버전으로 같은 날 진행한다.
- 자세한 과거 기록은 `WORK_LOG.md`에 있다.
