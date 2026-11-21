# 게임 미션 풀이 스크립트(farm) 작업

형식: `- [x] T001 [P] 설명 (파일 경로) — C번호`
`[P]`: 다른 파일을 고치고 끝나지 않은 작업에 의존하지 않아 다른 작업과 동시에 할 수 있음

## 단계 1: 기반 파일

- [x] T001 [P] 배치 스크립트 작성: `-Stage`(1~4), `-Save`(기본 `Save0`), `-SaveDir` 인자, 단계 파일 찾기, `dotnet run --project src/tfwrc -c Release -- --lang cs --toplevel`로 임시 폴더에 컴파일, 세이브 폴더 확인, `main.py`로 복사, 새 파일이면 다시 불러오기 안내 출력, 결과 경로·내용 출력. 사용자 폴더 경로는 `$env:USERPROFILE`로만 계산 (farm/deploy.ps1) — C2
- [x] T002 [P] 1단계 스크립트: 반복문 없이 `Harvest()` 나열 (farm/stages/Stage1Hay.cs) — C1, C3
- [x] T003 [P] 2단계 스크립트: `while (true) { Harvest(); }` (farm/stages/Stage2Loop.cs) — C1, C3
- [x] T004 [P] 3단계 스크립트: `while (true) { if (CanHarvest()) Harvest(); }` (farm/stages/Stage3Check.cs) — C1, C3
- [x] T005 [P] 4단계 스크립트: 3단계에 `Move(Direction.North)` 추가 (farm/stages/Stage4Move.cs) — C1, C3
- [x] T006 README 작성: 단계 표(파일, 먼저 있어야 할 해금, 얻으려는 해금, 쓰는 함수·문법, 대조 근거), 컴파일·배치 방법, 사용자 조작 순서(다시 불러오기, F5, 1단계 반복 실행, speed 뒤 2단계를 쓰지 말 것, 해금 뒤 Ctrl+S) (farm/README.md) — C5

체크포인트: 단계 1~4마다 `farm/deploy.ps1 -Stage <n> -SaveDir <스크래치 폴더>`를 실행해 종료 코드 0과 `main.py` 생성을 확인하고, 생성된 내용이 README 단계 표의 "쓰는 함수·문법"과 맞는지 본다. `farm/` 아래에서 사용자 폴더 경로(`C:\Users`, 사용자 이름)를 검색해 없음을 확인한다.

## 단계 2: 게임 진행

단계마다 다음 순서로 한다: 사용자에게 다음 해금의 비용·선행 조건을 묻는다 → 실제 순서가 예상과 다르면 단계 파일과 README 표를 맞춘다 → `farm/deploy.ps1 -Stage <n> -SaveDir <스크래치 폴더>`로 컴파일한다 → 그 `main.py`의 모든 줄을 배치 직전 `save.json` 해금 목록과 대조 근거로 대조한다(C3) → 통과하면 `farm/deploy.ps1 -Stage <n>`으로 `Save0`에 배치한다 → `Save0/main.py`가 대조한 스크래치 출력과 같은지 확인한다(C2) → 사용자가 실행하고 오류 여부를 알린다 → 사용자가 해금하고 저장(Ctrl+S)한 뒤 알린다 → `save.json`의 `unlocks`를 확인한다.

- [x] T007 1단계 진행: 처음 배치라 사용자에게 세이브 다시 불러오기를 요청하고, 기본 세이브 경로(`-Save Save0`, `$env:USERPROFILE` 기준) 동작을 확인하며, `loops` 해금까지 진행. `loops` 해금 뒤 `save.json`의 `unlocks`에 `true`·`false` 항목이 생겼는지 참고로 기록한다(판정에는 쓰지 않음, plan 오류·위험) (farm/stages/Stage1Hay.cs, farm/README.md) — C2, C3, C4
- [x] T008 2단계 진행: `speed` 해금까지 진행 (farm/stages/Stage2Loop.cs, farm/README.md) — C3, C4
- [x] T009 3단계 진행: `expand` 해금까지 진행 (farm/stages/Stage3Check.cs, farm/README.md) — C3, C4
- [x] T010 4단계 진행: `plant` 해금까지 진행하고, `save.json`의 `unlocks`에 네 해금이 모두 있는지 확인. 게임이 저장한 이름이 다르면(예: `expand_1`) 그 해금에 해당하는 실제 값을 확인해 검증 기록에 함께 적는다 (farm/stages/Stage4Move.cs, farm/README.md) — C3, C4

체크포인트: 마지막 저장 뒤 `save.json`의 `unlocks`에 `loops`, `speed`, `expand`, `plant`가 모두 있고(저장된 이름이 다르면 그 실제 값이 기록되어 있고), 단계마다 C3 대조 결과와 사용자의 오류 없음 답이 기록되어 있다.

## 단계 3: 기준 spec 반영

- [x] T011 기능 `farm-scripts`의 기준 spec 새로 작성: `파일:` 줄(`farm/deploy.ps1`, `farm/README.md`, `farm/stages/*.cs`), 요구 R1~R5(이번 C1~C5에서 옮김), 이력 한 줄(2026-11-21, farm-missions, R1~R5 추가, docs/specs/farm-missions/) (docs/features/farm-scripts.md) — C1, C2, C3, C4, C5

체크포인트: 기준 spec의 `파일:` 줄이 실제 `farm/` 파일과 맞고, R1~R5가 spec.md C1~C5와 같은 뜻이다.

## 의존 관계

- T001~T005는 서로 다른 파일이라 동시에 할 수 있다. T006은 단계 표에 단계 파일 이름과 내용이 필요하므로 T002~T005 뒤에 한다.
- 단계 2는 단계 1 체크포인트 뒤에 한다(배치 스크립트와 단계 파일이 있어야 게임에 넣을 수 있다).
- T007 → T008 → T009 → T010은 게임 진행 순서대로 한다. 앞 단계의 해금이 있어야 다음 단계 스크립트를 쓸 수 있다. 사용자가 알려 준 해금 순서가 다르면 T008~T010의 순서와 대상 해금을 그 순서로 바꿔 진행한다.
- T011은 모든 작업 뒤 마지막 구현 단계에 한다(규칙 workflow/spec-driven.md 3절 2번).
