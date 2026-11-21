# 게임 미션 풀이 스크립트(farm)

기능: farm-scripts(새 기능)
이슈: GitHub #1

## 무엇을, 왜

저장소의 컴파일러 `tfwrc`로 C# 스크립트를 작성·컴파일해 The Farmer Was Replaced 게임의 해금(미션)을 처음 상태부터 하나씩 풀어 간다. 컴파일러를 실제 게임 진행에 써 보는 예제이기도 하다.

이번 작업은 두 가지를 한다(D003).

1. **기반**: 저장소에 `farm/` 폴더를 만들어 게임 스크립트의 C# 소스를 두고(D002), 한 명령으로 컴파일해 게임 세이브 폴더에 넣는 스크립트를 만든다.
2. **초반 미션**: 처음 상태의 세이브에서 초반 해금 4개 `loops`, `speed`, `expand`, `plant`를 모두 얻을 때까지 단계별 스크립트를 쓴다. D003의 `loops → speed → expand → plant`는 예상 순서이고, 실제 순서는 사용자가 알려 주는 해금 트리의 비용과 선행 조건으로 정한다.

역할(D001):

- 에이전트: 스크립트 작성, 컴파일, 세이브 폴더 배치, 생성된 `.py`와 해금 목록 대조, `save.json`으로 진행 확인
- 사용자:
  - 해금 트리에서 다음 해금의 비용과 선행 조건을 확인해 알려 준다.
  - 에이전트가 새 파일을 배치했다고 알리면 세이브를 다시 불러온다.
  - 게임에서 스크립트를 실행(F5)하고, 실행 중 오류가 났는지 알려 준다.
  - 해금 트리에서 해금을 누른 뒤 게임에서 저장(Ctrl+S)하고 알린다.

게임의 제약(근거: 게임 문서 `StreamingAssets/Languages/EN/docs/first_program.md`, `docs/external_editor.md`, `docs/scripting/*.md`, `docs/unlocks/*.md`, `Strings/unlock_tooltips.txt`, `StreamingAssets/Languages/builtins.py`, 현재 세이브 `Saves/Save0/save.json`):

- 처음 상태의 세이브는 `grass`, `soil`, `harvest`, `pass`, `do_a_flip`, `pet_the_piggy`, `grassland`, `hay`, `straw_hat`, `tap`, `stats`, `comments`만 해금되어 있다. 반복문(`loops`), 함수 정의(`functions`), 변수(`variables`), 이동(`expand`) 등은 해금 전에는 쓸 수 없다.
- 게임은 세이브 폴더의 `.py` 파일을 코드 창으로 쓴다. 파일 감시 옵션이 켜져 있으면 바깥에서 고친 내용이 바로 반영되지만, 파일을 새로 만들거나 지우면 세이브를 다시 불러와야 한다. 이 작업은 파일 감시 옵션이 켜져 있다는 것을 전제로 한다.
- 해금 비용은 텍스트 문서에 없고 게임 해금 트리 화면에만 표시된다.
- 해금과 그 해금으로 쓸 수 있게 되는 함수·문법의 대응은 `save.json`에도, 게임의 `builtins.py`에도 없다. 대응은 게임 EN 문서로 판정한다(이하 "대조 근거"): `docs/first_program.md`(처음 쓸 수 있는 명령 `harvest()`, `do_a_flip()`), `docs/scripting/*.md`(문법별 설명, 예: `comments.md`의 `#` 주석), `docs/unlocks/*.md`(해금별로 열리는 함수·상수, 예: `expand_1.md`의 `move()`와 `North`·`East`·`South`·`West`, `speed.md`의 `if`와 `can_harvest()`), `Strings/unlock_tooltips.txt`의 설명 문장과 예시 코드. 해금과 문서는 이름(예: `comments` ↔ `scripting/comments.md`, `expand` ↔ `unlocks/expand_1.md`)이나 문서 본문의 "이 해금으로 열린다"는 설명으로 대응시킨다. 대조 근거로 해금 여부를 확인할 수 없는 함수와 문법은 쓰지 않는다.

이번 작업에 넣지 않는 것: `plant` 다음 해금들(다음 작업에서 한다), 컴파일러(`src/`) 자체의 변경.

## 완료 조건

- C1. `farm/` 아래에 단계별 C# 스크립트 소스가 있고, `tfwrc --lang cs`로 오류 없이 컴파일된다.
- C2. `farm/` 아래의 스크립트 한 번 실행으로 지정한 단계의 소스를 컴파일하고 결과 `.py`를 지정한 세이브 폴더(기본 `Save0`)에 넣는다. 스크립트에는 특정 사용자 폴더 경로를 고정해 적지 않는다.
- C3. 각 단계의 컴파일된 `.py`가 그 단계를 실행하는 시점의 `save.json`에 있는 해금으로 쓸 수 있다고 대조 근거(게임의 제약 넷째 항목)로 확인되는 함수와 문법만 쓰는지 에이전트가 대조해 확인하고, 사용자가 게임에서 실행했을 때 오류가 나지 않았음을 알려 준다.
- C4. 사용자가 각 단계 스크립트를 실행해 모은 자원으로 해금하고 게임에서 저장(Ctrl+S)한 뒤 알리면, 에이전트가 읽은 `save.json`의 `unlocks`에 `loops`, `speed`, `expand`, `plant` 해금이 모두 들어 있다.
- C5. `farm/README.md`에 단계마다 실행할 스크립트, 그 단계를 쓰기 위해 먼저 있어야 할 해금, 그 단계로 얻으려는 해금, 컴파일·배치 방법이 적혀 있다.
