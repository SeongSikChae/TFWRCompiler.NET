# 게임 미션 풀이 스크립트(farm) 계획

## 요약

`farm/` 아래에 해금 단계마다 C# 스크립트 하나(`farm/stages/StageN*.cs`)를 두고, PowerShell 스크립트 `farm/deploy.ps1`이 지정한 단계를 `tfwrc --lang cs --toplevel`로 컴파일한다. 결과는 세이브 폴더에 늘 같은 이름 `main.py`로 넣는다. 파일 이름이 늘 같으므로 세이브를 다시 불러와야 하는 것은 처음 배치할 때 한 번뿐이고, 그 뒤 단계를 바꿀 때는 파일 감시가 내용을 반영한다. 단계마다 쓰는 함수·문법과 그 대조 근거를 `farm/README.md`의 단계 표에 적는다.

## 바꿀 파일·구조

- `farm/stages/Stage1Hay.cs`: 새 파일. 처음 상태용. 반복문 없이 `Harvest()`를 여러 줄 나열한다(`loops` 해금용 건초 모으기).
- `farm/stages/Stage2Loop.cs`: 새 파일. `loops` 뒤. `while (true) { Harvest(); }`.
- `farm/stages/Stage3Check.cs`: 새 파일. `speed` 뒤. `while (true) { if (CanHarvest()) Harvest(); }`.
- `farm/stages/Stage4Move.cs`: 새 파일. `expand` 뒤. 3번에 `Move(Direction.North)`를 더해 늘어난 땅을 돈다.
- `farm/deploy.ps1`: 새 파일. 단계 번호와 세이브 이름을 받아 컴파일하고 `main.py`로 복사한다.
- `farm/README.md`: 새 파일. 단계 표(파일, 먼저 있어야 할 해금, 얻으려는 해금, 쓰는 함수·문법과 대조 근거 문서), 컴파일·배치 방법, 사용자 조작 순서.
- `docs/features/farm-scripts.md`: 새 파일. 기능 `farm-scripts`의 기준 spec(마지막 구현 단계에서 만든다).

단계 파일은 D003의 예상 순서(`loops → speed → expand → plant`)를 기준으로 짠다. `plant`는 이번 작업의 마지막 목표 해금이라 `plant`를 쓰는 단계 스크립트는 만들지 않는다. 사용자가 알려 준 해금 트리 정보로 순서가 달라지면 단계 파일의 내용과 번호, README 표를 그 순서에 맞춘다(spec 무엇을·왜 2번이 허용하는 범위라 의도 변경이 아니다).

## 결정

- 배치 파일 이름을 단계와 상관없이 `main.py` 하나로 고정한다: 게임은 새 파일이 생기면 세이브를 다시 불러와야 하므로, 이름을 고정하면 다시 불러오기가 처음 한 번으로 줄고 단계 전환은 파일 감시로 반영된다. / 검토한 대안: 단계마다 다른 파일 이름(`Stage2Loop.py` 등)으로 배치 — 단계를 바꿀 때마다 새 파일이 생겨 다시 불러와야 하고, 게임 안에 코드 창이 쌓여 어느 것을 실행할지 헷갈려 고르지 않았다.
- 모든 단계를 `--toplevel`로 컴파일한다: 기본 출력은 `def main():`과 `if __name__ == "__main__":`를 넣는데, `def`는 `functions` 해금이 필요하고 `__name__` 비교는 대조 근거로 확인할 수 없다(spec 게임의 제약 넷째 항목). / 검토한 대안: 기본 출력 — 이번 범위의 어느 단계에서도 `functions`가 없어 고르지 않았다.
- 컴파일러 실행은 `dotnet run --project src/tfwrc -c Release --`로 한다: 저장소 안의 컴파일러를 그대로 쓰고, 빌드가 안 되어 있으면 자동으로 빌드된다. / 검토한 대안: 빌드된 `tfwrc.exe`를 직접 호출 — 빌드 출력 경로(`bin/Release/<TFM>/`)가 대상 프레임워크에 따라 바뀌어 스크립트가 경로를 찾아야 하므로 고르지 않았다.
- 세이브 폴더는 `$env:USERPROFILE\AppData\LocalLow\TheFarmerWasReplaced\TheFarmerWasReplaced\Saves\<세이브 이름>`로 계산하고, `-SaveDir`로 직접 지정할 수도 있게 한다: 사용자 폴더 경로를 고정해 적지 않는다(spec C2, 규칙 workflow/repository-content.md). 경로는 게임 문서 `docs/external_editor.md`의 Windows 위치를 따른다. / 검토한 대안: 경로 하드코딩 — C2와 규칙에 어긋나 고르지 않았다.
- `farm/`에 `.csproj`를 두지 않는다: C1은 `tfwrc`로 컴파일되는지만 요구한다. 프로젝트 파일을 두면 IDE 자동 완성은 좋아지지만 `Main`이 여러 개(단계마다) 생겨 `dotnet build`가 실패하므로 별도 설정이 필요하다. / 검토한 대안: 단계마다 별도 프로젝트 — 이번 범위에 비해 파일이 많아져 고르지 않았다.
- C3의 대조는 사람이 읽고 표로 남긴다: 단계마다 컴파일된 `main.py`의 모든 줄을 README 단계 표의 "쓰는 함수·문법"과 대조하고, 그 결과를 검증 보고에 적는다. 단계 스크립트가 짧아(10줄 안팎) 자동 검사기를 만드는 것보다 확실하다. / 검토한 대안: 허용 목록으로 토큰을 검사하는 스크립트 — 해금마다 허용 토큰 목록을 따로 관리해야 하고 이번 범위의 단계 네 개에는 과하여 고르지 않았다.

## 인터페이스·데이터

`farm/deploy.ps1`:

```
pwsh farm/deploy.ps1 -Stage <1-4> [-Save <세이브 이름, 기본 Save0>] [-SaveDir <세이브 폴더 직접 지정>]
```

1. `$PSScriptRoot`로 저장소 루트(`farm/`의 부모)를 찾는다.
2. `farm/stages/Stage<Stage>*.cs` 하나를 찾는다(없거나 여러 개면 오류로 끝낸다).
3. 임시 폴더를 출력 폴더로 `dotnet run --project <루트>/src/tfwrc -c Release -- --lang cs --toplevel --out <임시 폴더> <단계 파일>`을 실행한다. 종료 코드가 0이 아니면 오류로 끝낸다.
4. 세이브 폴더가 없으면 오류로 끝낸다(게임을 한 번도 실행하지 않았거나 세이브 이름이 틀림).
5. 생성된 `.py` 하나를 `<세이브 폴더>/main.py`로 복사한다. 복사 전에 `main.py`가 없었으면 "새 파일이므로 게임에서 세이브를 다시 불러오세요"를 출력한다.
6. 복사한 경로와 `main.py` 내용을 출력한다.

단계 표(README와 같음, 예상 순서 기준):

| 단계 | 파일 | 먼저 있어야 할 해금 | 얻으려는 해금 | 쓰는 함수·문법 | 대조 근거 |
|---|---|---|---|---|---|
| 1 | `Stage1Hay.cs` | 처음 상태 | `loops` | `harvest()`, `#` 주석 | `docs/first_program.md`, `docs/scripting/comments.md` |
| 2 | `Stage2Loop.cs` | `loops` | `speed` | 1 + `while True:` | `unlock_tooltips.txt` `@unlock_descr_loops`, `docs/scripting/while.md`(`while`과 `True`·`False`를 연다) |
| 3 | `Stage3Check.cs` | `loops`, `speed` | `expand` | 2 + `if`, `can_harvest()` | `docs/unlocks/speed.md` |
| 4 | `Stage4Move.cs` | `loops`, `speed`, `expand` | `plant` | 3 + `move()`, `North` | `docs/unlocks/expand_1.md` |

## 오류·위험

- 실제 해금 순서가 예상과 다를 수 있다: 사용자가 알려 준 비용·선행 조건으로 단계 파일과 표를 바꾼다. 예를 들어 `plant`가 `expand`보다 먼저면 4단계가 `plant` 앞 단계가 되지 않도록 순서를 바꾼다.
- 1단계는 반복문이 없어 한 번 실행하면 나열한 줄 수만큼만 수확한다: 사용자가 `loops` 비용만큼 건초가 모일 때까지 F5를 여러 번 누른다. README에 적는다.
- `speed` 뒤에는 수확이 풀이 자라는 속도보다 빨라 그냥 `harvest()`를 반복하면 수확량이 0이 된다(`docs/unlocks/speed.md`): 3단계부터 `can_harvest()`로 확인한다. 2단계 스크립트를 `speed` 뒤에도 계속 쓰지 않도록 README에 적는다.
- `while True:`의 `True`: `docs/scripting/while.md`에 따르면 `loops` 해금이 `while`과 함께 `True`·`False`를 연다. 2단계의 C3 대조는 이 문서를 근거로 한다. `save.json`에 `true`·`false` 항목이 생기는지는 참고로만 기록한다.
- `dotnet run`의 첫 실행은 빌드 때문에 느리다(수십 초): 동작에는 문제가 없다.
- 컴파일러가 C# 구문을 예상과 다르게 출력할 수 있다: 검증에서 생성된 `main.py`를 직접 읽어 대조한다(C3).

## 검증 전략

- C1: `deploy.ps1`을 단계 1~4로 각각 실행해 컴파일러 종료 코드 0과 출력 파일 생성을 확인한다.
- C2: `deploy.ps1 -Stage <n>` 실행 뒤 `Saves/Save0/main.py`가 생성된 내용과 같은지 확인한다. 스크립트 본문에 사용자 이름이 든 경로가 없는지 검색한다(`Select-String`으로 `C:\Users`, 사용자 이름 검색).
- C3: 단계마다 배치 직전의 `save.json` 해금 목록을 읽고, 생성된 `main.py`의 모든 줄이 단계 표의 "쓰는 함수·문법"과 그 대조 근거에 맞는지 대조한다. 사용자가 실행했을 때 오류가 없었다는 답을 받는다.
- C4: 사용자가 마지막 해금 뒤 저장했다고 알리면 `save.json`의 `unlocks`에 `loops`, `speed`, `expand`, `plant`가 있는지 확인한다. 게임이 저장하는 해금 이름이 다르면(예: 단계 번호가 붙은 이름) 실제 값을 보고에 함께 적는다.
- C5: README의 단계 표와 사용법 절을 읽어 네 가지 항목(실행할 스크립트, 먼저 있어야 할 해금, 얻으려는 해금, 컴파일·배치 방법)이 단계마다 있는지 확인한다.

## 원칙 점검

- 적용 규칙:
  - 전역 `language-preference.md`: 대화는 한국어. 코드와 주석의 언어는 저장소 규칙을 따른다. 이 저장소는 README·문서가 한국어이고 코드 주석이 영어(`src/TFWR.Api/Game.cs`)라 `farm/README.md`는 한국어, `.cs`·`.ps1` 주석은 영어로 쓴다.
  - MCP rule `workflow/spec-driven.md`: 이 문서 체계와 검토 절차.
  - MCP rule `git/github-issue.md`: 이슈 #1을 참조한다. 커밋·push는 승인 뒤에 한다.
  - MCP rule `workflow/repository-content.md`: 저장소 파일에 사용자 폴더 경로·개인 정보를 넣지 않는다. 경로는 저장소 기준 상대 경로와 `$env:USERPROFILE`로 쓴다.
  - 전역 `portable-python.md`: Python을 실행하지 않으므로 해당 없음(게임 스크립트 `.py`는 게임이 실행한다).
- 충돌: 없음
