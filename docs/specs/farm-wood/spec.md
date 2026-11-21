# 게임 미션 풀이 스크립트 나무 단계(farm-wood)

기능: farm-scripts(기준 spec docs/features/farm-scripts.md)
이슈: GitHub #2

## 무엇을, 왜

이전 작업(farm-missions, #1)에서 처음 세이브부터 초반 해금 4개(`loops`, `speed`, `expand`, `plant`)를 `farm/` 단계 스크립트로 풀었다. 이어서 덤불을 심어 나무를 모으고, 건초와 나무로 다음 해금 5개를 얻는 단계 스크립트를 더한다(D001).

- `expand` 2레벨
- `speed` 2레벨
- `carrots`
- `operators`
- `debug`

해금 순서는 단계마다 다시 정한다. 비용과 선행 조건은 게임 에셋에서 읽은 값을 쓰되, 단계마다 사용자가 해금 트리 화면과 같은지 확인해 알려 준다.

역할(이전 작업과 같다):

- 에이전트: 단계 스크립트 작성, 컴파일, 세이브 폴더 배치, 생성된 `.py`와 해금 목록 대조, `save.json`으로 진행 확인
- 사용자:
  - 해금 트리에서 다음 해금의 비용과 선행 조건을 확인해 알려 준다.
  - 에이전트가 새 파일을 배치했다고 알리면 세이브를 다시 불러온다.
  - 게임에서 스크립트를 실행(F5)하고, 실행 중 오류가 났는지 알려 준다.
  - 덤불 단계를 처음 실행해 나무가 생기면, 해금하기 전에 한 번 저장(Ctrl+S)하고 알린다(덤불이 나무를 주는지 `save.json`의 `wood`로 확인하기 위해).
  - 해금 트리에서 해금을 누른 뒤 게임에서 저장(Ctrl+S)하고 알린다.

기준 spec 반영: R1~R3은 새 단계에도 그대로 적용된다. R5를 "README에 단계마다 실행할 스크립트, 먼저 있어야 할 해금, 얻으려는 해금, 쓰는 함수·문법과 대조 근거, 컴파일·배치 방법이 적혀 있다"로 바꾸고(C5), R6 "`save.json`의 `unlocks`에 `expand` 2레벨, `speed` 2레벨, `carrots`, `operators`, `debug`에 해당하는 항목(2레벨은 `expand_2`, `speed_2`)이 있거나, 레벨 해금의 저장이 예상과 달라 항목이 없으면 사용자가 해금 트리 화면에서 그 레벨을 확인해 알려 준 것으로 충족한다"를 더한다(C4, D003). R4는 "`save.json`의 `unlocks`에 `loops`, `plant`가 있고, `speed`, `expand`는 그 이름 또는 레벨 항목(`<이름>_<레벨>`)이 있다"로 바꾼다. 레벨이 오르면 해금 이름이 바뀌어 레벨 없는 항목이 사라지기 때문이다(D004).

게임의 제약(근거: 게임 문서 `StreamingAssets/Languages/EN/docs/unlocks/plant.md`, `docs/unlocks/trees.md`, `docs/unlocks/carrots.md`, `docs/unlocks/expand_2.md`, `docs/scripting/for.md`, `docs/scripting/operators.md`, `docs/scripting/debug.md`, `Strings/unlock_tooltips.txt`, 현재 세이브 `Saves/Save0/save.json`, 이전 플레이 백업 `Backup/Save0_backup1024/save.json`, 게임 에셋 `TheFarmerWasReplaced_Data/resources.assets`):

- 지금 세이브의 해금은 처음 12개에 `loops`, `true`, `false`, `speed`, `expand`, `north`, `south`, `east`, `west`, `plant`, `entities`가 더해진 23개이고, 아이템은 건초 10개뿐이다.
- 나무는 덤불(`plant(Entities.Bush)`, `plant.md`)을 수확해 얻는다. `docs/unlocks/trees.md`가 "나무는 덤불보다 나무를 얻기 좋은 방법"이라고 적어 덤불도 나무를 준다는 것을 뒷받침하며, 덤불 단계를 처음 실행한 뒤 `save.json`의 `wood` 증가로 확인한다.
- `variables`가 해금되지 않아 대입(`=`)과 대입 연산자는 쓰지 않는다(`operators.md`). `for`의 반복 변수(`for i in range(...)`)는 `expand` 2레벨이 여는 `for` 문법에 포함된다(`for.md`, `expand_2.md`).
- `expand` 2레벨은 농장을 정사각형으로 넓히고 `for` 반복문, `range()`, `get_world_size()`를 연다(`expand_2.md`, `for.md`).
- 게임 에셋에서 읽은 비용: `expand` 2레벨 나무 20, `speed` 2레벨 나무 20, `carrots` 나무 50, `operators` 건초 150 + 나무 10, `debug` 건초 50 + 나무 50. 선행 해금은 `expand`·`speed`는 같은 해금의 1레벨, `carrots`·`operators`·`debug`는 `plant`다.
- 레벨 해금은 레벨이 오르면 해금 이름이 `<이름>_<레벨>`로 바뀌어 저장된다(근거: 이전 플레이 백업 `Backup/Save0_backup1024/save.json`에 `grass_4`, `speed_5`, `expand_6`이 있고 레벨 없는 `speed`·`expand`는 없다). 그래서 2레벨은 `expand_2`, `speed_2`로 저장될 것으로 본다.
- 해금과 함수·문법의 대응은 이전 작업과 같은 대조 근거로 판정한다(기준 spec R3): 게임 EN 문서 `docs/first_program.md`, `docs/scripting/*.md`, `docs/unlocks/*.md`, `Strings/unlock_tooltips.txt`의 설명 문장과 예시 코드. 대조 근거로 해금 여부를 확인할 수 없는 함수와 문법은 쓰지 않는다.
- 파일 감시 옵션이 켜져 있다는 것을 전제로 한다. `Save0/main.py`는 이미 있으므로, 같은 이름으로 배치하면 세이브를 다시 불러오지 않아도 된다.

이번 작업에 넣지 않는 것: 다섯 해금으로 새로 열리는 기능(당근 심기, 연산자, `print()` 등)을 써서 얻는 다음 해금(다음 작업에서 한다), 컴파일러(`src/`) 자체의 변경.

## 완료 조건

- C1. `farm/stages/` 아래에 이번 작업의 새 단계 C# 스크립트 소스가 있고, 이전 단계와 함께 `farm/deploy.ps1`로 오류 없이 컴파일된다.
- C2. 새 단계도 `farm/deploy.ps1 -Stage <번호>` 한 번 실행으로 컴파일되어 지정한 세이브 폴더(기본 `Save0`)에 `main.py`로 배치된다.
- C3. 각 새 단계의 컴파일된 `.py`가 그 단계를 실행하는 시점의 `save.json`에 있는 해금으로 쓸 수 있다고 대조 근거로 확인되는 함수와 문법만 쓰는지 에이전트가 대조해 확인하고, 사용자가 게임에서 실행했을 때 오류가 나지 않았음을 알려 준다. 레벨 해금의 저장이 예상과 달라 `save.json`에 항목이 없으면, 사용자가 해금 트리 화면에서 그 레벨을 확인해 알려 준 것을 그 해금이 있는 것으로 본다(C4와 같은 기준).
- C4. 사용자가 새 단계 스크립트를 실행해 모은 자원으로 해금하고 게임에서 저장(Ctrl+S)한 뒤 알리면, 에이전트가 읽은 `save.json`의 `unlocks`에 `expand` 2레벨, `speed` 2레벨, `carrots`, `operators`, `debug`에 해당하는 항목(2레벨은 `expand_2`, `speed_2`)이 있거나, 레벨 해금의 저장이 예상과 달라 항목이 없으면 사용자가 해금 트리 화면에서 그 레벨을 확인해 알려 준 것으로 충족한다. 실제 값은 검증 기록에 적는다(D002).
- C5. `farm/README.md`의 단계 표와 주의 사항에 새 단계마다 실행할 스크립트, 먼저 있어야 할 해금, 얻으려는 해금, 쓰는 함수·문법과 대조 근거가 적혀 있고, 컴파일·배치 방법이 새 단계에도 맞게 적혀 있다.
