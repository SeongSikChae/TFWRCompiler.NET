# 게임 미션 풀이 스크립트 나무 단계(farm-wood) 작업

형식: `- [x] T001 [P] 설명 (파일 경로) — C번호`
`[P]`: 다른 파일을 고치고 끝나지 않은 작업에 의존하지 않아 다른 작업과 동시에 할 수 있음

## 단계 1: 단계 파일과 README

- [x] T001 [P] 5단계 스크립트: `while (true) { if (CanHarvest()) { Harvest(); Plant(Entities.Bush); } Move(Direction.North); }` (farm/stages/Stage5Bush.cs) — C1, C3
- [x] T002 [P] 6단계 스크립트: `while (true) { for (var i = 0; i < GetWorldSize(); i++) { if (CanHarvest()) { Harvest(); Plant(Entities.Bush); } Move(Direction.North); } Move(Direction.East); }` (farm/stages/Stage6BushGrid.cs) — C1, C3
- [x] T003 [P] 7단계 스크립트: 6단계에서 `Plant` 호출을 뺀 순회 (farm/stages/Stage7HayGrid.cs) — C1, C3
- [x] T004 README 갱신: 단계 표에 5~7행(파일, 먼저 있어야 할 해금, 얻으려는 해금, 쓰는 함수·문법, 대조 근거) 추가, 단계별 주의(5단계 첫 실행 뒤 해금 전에 저장, 6단계에서 `speed` 2레벨·`carrots`를 해금한 뒤 `debug`·`operators`용 나무 60이 남았을 때(`save.json`의 `wood` 보유량 기준) 7단계로 넘어감, 7단계 초반 수확량이 낮음) 추가, '게임에서 하는 일' 절에 "`main.py`가 이미 있으면 다시 불러오지 않고 다음 단계를 배치한다" 보강 (farm/README.md) — C5

체크포인트: `farm/deploy.ps1 -Stage <n> -SaveDir <스크래치 폴더>`를 1~7단계 모두 실행해 종료 코드 0과 `main.py` 생성을 확인하고, 5~7단계 출력이 README 단계 표의 "쓰는 함수·문법"과 맞는지 본다(대입문이 없는지 포함). README 단계 표 5~7행의 모든 열(파일, 먼저 있어야 할 해금, 얻으려는 해금, 쓰는 함수·문법, 대조 근거)과 단계별 주의가 있는지, '컴파일·배치' 절과 '게임에서 하는 일' 절이 5~7단계에도 맞는지 읽어 확인한다(C5).

## 단계 2: 게임 진행

단계마다 다음 순서로 한다: 사용자에게 다음 해금의 비용·선행 조건이 화면과 같은지 묻는다 → 실제 순서가 예상과 다르면 진행 순서와 README 표를 맞춘다 → `farm/deploy.ps1 -Stage <n> -SaveDir <스크래치 폴더>`로 컴파일한다 → 그 `main.py`의 모든 줄을 배치 직전 `save.json` 해금 목록과 대조 근거로 대조한다(C3, 레벨 항목이 없으면 사용자 화면 확인으로 대신) → 통과하면 `farm/deploy.ps1 -Stage <n>`으로 `Save0`에 배치한다 → `Save0/main.py`가 대조본과 같은지 해시로 확인한다(C2) → 사용자가 실행하고 오류 여부를 알린다 → 사용자가 해금하고 저장(Ctrl+S)한 뒤 알린다 → `save.json`의 `unlocks`를 확인한다(C4).

- [x] T005 5단계 진행: 배치 후 사용자가 첫 실행 뒤 해금 전에 저장하면 `save.json`의 `wood` 증가를 확인하고(덤불→나무 전제), `wood`가 늘지 않았으면 다음 단계로 가지 않고 사용자에게 알려 원인을 찾는다. 진행 중 `save.json`의 `wood`로 진행 상황을 사용자에게 알려 주며, 나무 20을 모아 `expand` 2레벨 해금까지 진행. `unlocks`의 실제 레벨 항목 이름을 기록 (farm/stages/Stage5Bush.cs, farm/README.md) — C2, C3, C4
- [x] T006 6단계 진행: `speed` 2레벨(나무 20)·`carrots`(나무 50) 해금까지 진행하고, 7단계로 넘어가기 전에 `debug`·`operators`용 나무(60)를 모은다. 진행 중 `save.json`의 `wood`로 진행 상황을 사용자에게 알려 준다 (farm/stages/Stage6BushGrid.cs, farm/README.md) — C2, C3, C4
- [x] T007 7단계 진행: 건초 200을 모아 `debug`·`operators` 해금까지 진행하고, `save.json`에서 다섯 해금을 모두 확인. 레벨 항목이 다르면 사용자 화면 확인과 실제 값을 기록 (farm/stages/Stage7HayGrid.cs, farm/README.md) — C2, C3, C4

체크포인트: 마지막 저장 뒤 `save.json`의 `unlocks`에 `expand_2`, `speed_2`(저장 이름이 다르면 사용자 화면 확인), `carrots`, `operators`, `debug`가 있고, 단계마다 C3 대조 결과와 사용자의 오류 없음 답, 덤불→나무 확인 결과가 기록되어 있다.

## 단계 3: 기준 spec 반영

- [x] T008 기능 `farm-scripts` 기준 spec 갱신: `파일:` 줄에 `farm/stages/Stage5Bush.cs`, `Stage6BushGrid.cs`, `Stage7HayGrid.cs` 추가, R4를 "`loops`, `plant`가 있고, `speed`, `expand`는 그 이름 또는 레벨 항목(`<이름>_<레벨>`)이 있다"로 바꿈, R5를 "쓰는 함수·문법과 대조 근거"를 포함하도록 바꿈, R6 추가, 이력에 한 줄(2026-11-21, farm-wood, R4 바꿈·R5 바꿈·R6 추가, docs/specs/farm-wood/) (docs/features/farm-scripts.md) — C1, C2, C3, C4, C5

체크포인트: 기준 spec의 `파일:` 줄이 실제 `farm/` 파일과 맞고, R4·R5·R6이 spec "기준 spec 반영"과 같은 뜻이며 현재 `save.json`으로 R4·R6을 판정할 수 있다.

## 의존 관계

- T001~T003은 서로 다른 파일이라 동시에 할 수 있다. T004는 단계 표에 새 단계 파일 이름과 내용이 필요하므로 T001~T003 뒤에 한다.
- 단계 2는 단계 1 체크포인트 뒤에 한다.
- T005 → T006 → T007은 게임 진행 순서대로 한다. 6·7단계는 `expand` 2레벨(T005)이 있어야 쓸 수 있고, 7단계는 나무를 다 모은 뒤(T006) 넘어간다. 사용자가 알려 준 순서가 다르면 그 순서로 바꿔 진행한다.
- T008은 모든 작업 뒤 마지막 구현 단계에 한다(규칙 workflow/spec-driven.md 3절 2번).
