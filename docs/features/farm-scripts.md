# farm-scripts

파일: farm/deploy.ps1, farm/README.md, farm/stages/Stage1Hay.cs, farm/stages/Stage2Loop.cs, farm/stages/Stage3Check.cs, farm/stages/Stage4Move.cs

## 요구(완료 조건)

- R1. `farm/` 아래에 단계별 C# 스크립트 소스가 있고, `tfwrc --lang cs`로 오류 없이 컴파일된다.
- R2. `farm/` 아래의 스크립트 한 번 실행으로 지정한 단계의 소스를 컴파일하고 결과 `.py`를 지정한 세이브 폴더(기본 `Save0`)에 넣는다. 스크립트에는 특정 사용자 폴더 경로를 고정해 적지 않는다.
- R3. 각 단계의 컴파일된 `.py`가 그 단계를 실행하는 시점의 `save.json`에 있는 해금으로 쓸 수 있다고 대조 근거(게임 EN 문서 `docs/first_program.md`, `docs/scripting/*.md`, `docs/unlocks/*.md`, `Strings/unlock_tooltips.txt`의 설명 문장과 예시 코드)로 확인되는 함수와 문법만 쓰는지 에이전트가 대조해 확인하고, 사용자가 게임에서 실행했을 때 오류가 나지 않았음을 알려 준다.
- R4. 사용자가 각 단계 스크립트를 실행해 모은 자원으로 해금하고 게임에서 저장(Ctrl+S)한 뒤 알리면, 에이전트가 읽은 `save.json`의 `unlocks`에 `loops`, `speed`, `expand`, `plant` 해금이 모두 들어 있다.
- R5. `farm/README.md`에 단계마다 실행할 스크립트, 그 단계를 쓰기 위해 먼저 있어야 할 해금, 그 단계로 얻으려는 해금, 컴파일·배치 방법이 적혀 있다.

## 이력

| 날짜 | 작업 | 바꾼 요구 | 변경 폴더 |
|---|---|---|---|
| 2026-11-21 | farm-missions | R1~R5 추가 | docs/specs/farm-missions/ |

표에 없는 이전 변경: 기록 없음
