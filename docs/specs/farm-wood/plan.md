# 게임 미션 풀이 스크립트 나무 단계(farm-wood) 계획

## 요약

`farm/stages/`에 단계 스크립트 3개(5~7단계)를 더한다. 5단계는 지금 있는 기능(1×3 땅, `while`, `if`, `can_harvest()`, `move()`, `plant()`)으로 덤불을 심어 나무를 모은다. `expand` 2레벨로 `for`·`get_world_size()`가 열리면, 6단계는 정사각형 농장을 열 단위로 돌며 덤불을 심고, 7단계는 같은 순회로 심지 않고 수확만 해 건초를 모은다. 배치는 기존 `farm/deploy.ps1`을 그대로 쓴다(`-Stage 5~7`). README 단계 표와 주의 사항을 늘리고, 기준 spec `docs/features/farm-scripts.md`의 R4·R5를 바꾸고 R6을 더한다.

## 바꿀 파일·구조

- `farm/stages/Stage5Bush.cs`: 새 파일. `plant` 뒤, 1×3 땅. `while (true) { if (CanHarvest()) { Harvest(); Plant(Entities.Bush); } Move(Direction.North); }`.
- `farm/stages/Stage6BushGrid.cs`: 새 파일. `expand` 2레벨 뒤. `while (true) { for (var i = 0; i < GetWorldSize(); i++) { if (CanHarvest()) { Harvest(); Plant(Entities.Bush); } Move(Direction.North); } Move(Direction.East); }`.
- `farm/stages/Stage7HayGrid.cs`: 새 파일. `expand` 2레벨 뒤. 6단계에서 `Plant`를 뺀 순회. 덤불을 한 번 수확한 칸은 풀로 돌아와 건초를 준다.
- `farm/README.md`: 단계 표에 5~7단계 행 추가, 단계별 주의 사항 추가. '게임에서 하는 일' 절에 "`main.py`가 이미 있으면 다시 불러오지 않고 다음 단계를 배치한다"를 보강한다. '컴파일·배치' 절은 일반형(`-Stage <단계 번호>`)이라 바꾸지 않는다.
- `docs/features/farm-scripts.md`: `파일:` 줄에 새 단계 파일 3개를 더하고, R4·R5를 spec "기준 spec 반영"대로 바꾸고 R6을 더하며, 이력에 이번 작업 한 줄을 더한다.

`farm/deploy.ps1`은 바꾸지 않는다. 단계 번호로 `Stage<번호>*.cs`를 찾으므로 새 파일을 그대로 처리한다(이전 작업 체크포인트에서 `-Stage 9`가 "파일 없음" 오류로 끝나는 것을 확인했다).

## 결정

- 단계 진행 순서를 5단계 → `expand` 2레벨 → 6단계 → `speed` 2레벨·`carrots` → 7단계 → `debug`·`operators`로 정한다: 나무가 필요한 해금(`expand` 2레벨 20, `speed` 2레벨 20, `carrots` 50, `debug` 50, `operators` 10 = 나무 150)을 6단계까지 먼저 다 모으고, 건초가 필요한 해금(`debug` 50, `operators` 150 = 건초 200)은 7단계로 모은다. 변수와 연산자가 없어 한 스크립트에서 칸마다 덤불과 풀을 나눠 심을 수 없으므로 자원별로 단계를 나눈다. / 검토한 대안: 덤불과 풀을 섞는 한 단계 — 칸 위치를 구별하려면 `get_pos_x()`(senses)와 `%`(operators)가 필요해 이번 시점에 쓸 수 없어 고르지 않았다.
- 덤불 심기는 `if (CanHarvest())` 블록 안에서 `Harvest()` 바로 뒤에 한다: 다 자란 것을 거둔 칸에만 심어, 아직 자라는 덤불 위에 다시 심지 않는다. 처음에는 모든 칸이 풀이라 풀을 거두고 덤불을 심는다. / 검토한 대안: 매 칸 무조건 `Plant` — 자라는 중인 덤불 위에 심는 호출이 반복되어 실패 반환이 계속되므로 고르지 않았다.
- 6·7단계의 순회는 `expand_2.md` 힌트의 "북쪽으로 한 바퀴, 동쪽으로 한 칸"을 `for (var i = 0; i < GetWorldSize(); i++)`로 쓴다: 컴파일 결과가 `for i in range(get_world_size()):`로 나와 `expand_2.md`·`for.md`가 여는 문법과 같고(스크래치 시험으로 확인), 농장이 더 넓어져도 그대로 동작한다. / 검토한 대안: 칸 수만큼 `Move`를 나열 — 농장 크기가 바뀌면 깨지므로 고르지 않았다.
- `speed` 2레벨과 `carrots`는 6단계 실행 중에 해금한다. 두 해금은 새 스크립트 기능을 쓰지 않으므로 단계를 따로 두지 않는다.
- 덤불이 나무를 주는지(spec 게임의 제약 둘째 항목)는 5단계 첫 실행 뒤 사용자가 해금 전에 저장하면 `save.json`의 `wood`로 확인한다. 늘지 않았으면 다음 단계로 가지 않고 사용자에게 알려 원인을 찾는다.
- `debug`·`operators` 뒤에는 새 단계를 만들지 않는다: 두 해금이 여는 `print()`·연산자를 쓰는 것은 다음 작업 범위다(spec "넣지 않는 것").

## 인터페이스·데이터

단계 표(README에 더할 행, 예상 순서 기준):

| 단계 | 파일 | 먼저 있어야 할 해금 | 얻으려는 해금 | 쓰는 함수·문법 | 대조 근거 |
|---|---|---|---|---|---|
| 5 | `Stage5Bush.cs` | `loops`, `speed`, `expand`, `plant` | `expand` 2레벨 | 4단계 + `plant(Entities.Bush)` | `docs/unlocks/plant.md`, `unlock_tooltips.txt` `@unlock_descr_plant` |
| 6 | `Stage6BushGrid.cs` | 5단계 + `expand` 2레벨 | `speed` 2레벨, `carrots` | 5단계 + `for i in range(...)`, `get_world_size()`, `East` | `docs/unlocks/expand_2.md`, `docs/scripting/for.md`, `docs/unlocks/expand_1.md` |
| 7 | `Stage7HayGrid.cs` | 6단계와 같음 | `debug`, `operators` | 6단계에서 `plant` 뺌 | 6단계와 같음 |

`save.json`의 아이템 이름: 건초 `hay`, 나무 `wood`(이전 플레이 백업에서 확인).

## 오류·위험

- 덤불이 다 자라는 데 걸리는 시간을 모른다: 1×3 땅에서 나무 20을 모으는 데 시간이 걸릴 수 있다. 사용자에게 진행 상황(`save.json`의 `wood`)을 알려 준다.
- `expand` 2레벨 뒤 농장 크기는 문서에 숫자로 나오지 않는다: 순회는 `get_world_size()`로 크기를 읽으므로 크기와 상관없이 동작한다.
- 7단계에서 덤불이 남아 있는 칸은 처음 한 번 나무를 주고 풀로 돌아온다: 건초 수확량이 잠시 낮다. 동작에는 문제가 없다.
- 레벨 해금의 실제 저장 이름이 `expand_2`·`speed_2`와 다를 수 있다: spec C3·C4대로 사용자의 화면 확인으로 대신하고 실제 값을 기록한다.
- 실제 해금 순서가 예상과 다를 수 있다: 사용자가 알려 준 비용·선행 조건으로 진행 순서와 README 표를 맞춘다.
- 사용자가 7단계로 넘어가기 전에 나무가 부족하면 `debug`(나무 50)를 못 얻는다: 6단계에서 나무를 누적 150까지 모은 뒤(즉 `speed` 2레벨·`carrots`를 해금하고 `debug`·`operators`용 나무 60이 남았을 때, `save.json`의 `wood` 보유량 기준) 7단계로 넘어가도록 README에 적는다.

## 검증 전략

- C1: `deploy.ps1 -Stage <n> -SaveDir <스크래치>`를 1~7단계 모두 실행해 종료 코드 0과 `main.py` 생성을 확인한다.
- C2: 새 단계마다 `deploy.ps1 -Stage <n>`(기본 `Save0`)으로 배치한 뒤 `Save0/main.py`가 스크래치 대조본과 같은지 해시로 확인한다.
- C3: 새 단계마다 배치 직전 `save.json` 해금 목록을 읽고, 생성된 `main.py`의 모든 줄을 단계 표의 "쓰는 함수·문법"과 대조 근거로 대조한다. 레벨 해금 항목이 없으면 사용자의 화면 확인을 그 해금이 있는 것으로 본다. 사용자가 실행 중 오류가 없었다고 알려 준다.
- C4: 마지막 해금 뒤 저장했다고 알리면 `save.json`의 `unlocks`에서 `expand_2`, `speed_2`, `carrots`, `operators`, `debug`를 확인한다. 레벨 항목이 다르면 사용자의 화면 확인과 실제 값을 기록한다. 덤불→나무 전제는 5단계 첫 실행 뒤 저장분의 `wood`로 확인한다.
- C5: README 단계 표의 5~7행과 주의 사항을 읽어 spec C5의 항목이 새 단계마다 있는지 확인하고, '컴파일·배치' 절과 '게임에서 하는 일' 절이 5~7단계에도 그대로 맞는지 읽어 확인한다.
- 기준 spec: `docs/features/farm-scripts.md`의 `파일:` 줄이 실제 `farm/` 파일과 맞고, R4·R5·R6이 spec "기준 spec 반영"과 같은 뜻인지 확인한다.

## 원칙 점검

- 적용 규칙:
  - 전역 `language-preference.md`: 대화는 한국어. `farm/README.md`·문서는 한국어, `.cs` 주석은 영어(이전 작업과 같은 저장소 관례).
  - MCP rule `workflow/spec-driven.md`: 변경 문서·검토 절차, 마지막 구현 단계에서 기준 spec 반영.
  - MCP rule `git/github-issue.md`: 이슈 #2 참조. 커밋·push는 승인 뒤.
  - MCP rule `workflow/repository-content.md`: 저장소 파일에 사용자 폴더 경로·개인 정보를 넣지 않는다. 백업 경로는 저장 폴더 기준 상대 경로(`Backup/...`)로만 적는다.
- 충돌: 없음
