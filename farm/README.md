# farm

[The Farmer Was Replaced](https://store.steampowered.com/app/2060160/The_Farmer_Was_Replaced/)의 해금(미션)을 처음 세이브부터 하나씩 풀어 가는 C# 스크립트 모음입니다. 저장소의 컴파일러 [`tfwrc`](../src/tfwrc/README.md)로 인게임 스크립트(`.py`)로 바꿔 게임에 넣습니다.

게임 언어는 해금할 때마다 기능이 늘어납니다. 그래서 단계마다 그 시점에 해금된 함수와 문법만 쓰는 스크립트를 따로 둡니다.

## 요구 사항

- .NET 10 SDK 이상 (저장소 [README](../README.md) 참고)
- PowerShell 7 (`pwsh`)
- 게임 옵션 **File Watcher** 켜기. 바깥에서 고친 코드 파일이 게임에 바로 반영됩니다.

## 단계

| 단계 | 파일 | 먼저 있어야 할 해금 | 얻으려는 해금 | 쓰는 함수·문법 | 대조 근거(게임 문서) |
|---|---|---|---|---|---|
| 1 | [`stages/Stage1Hay.cs`](stages/Stage1Hay.cs) | 처음 상태 | `loops` | `harvest()`, `#` 주석 | `docs/first_program.md`, `docs/scripting/comments.md` |
| 2 | [`stages/Stage2Loop.cs`](stages/Stage2Loop.cs) | `loops` | `speed` | 1단계 + `while True:` | `Strings/unlock_tooltips.txt`의 `@unlock_descr_loops`, `docs/scripting/while.md`(`while`과 `True`·`False`를 연다) |
| 3 | [`stages/Stage3Check.cs`](stages/Stage3Check.cs) | `loops`, `speed` | `expand` | 2단계 + `if`, `can_harvest()` | `docs/unlocks/speed.md` |
| 4 | [`stages/Stage4Move.cs`](stages/Stage4Move.cs) | `loops`, `speed`, `expand` | `plant` | 3단계 + `move()`, `North` | `docs/unlocks/expand_1.md` |
| 5 | [`stages/Stage5Bush.cs`](stages/Stage5Bush.cs) | `loops`, `speed`, `expand`, `plant` | `expand` 2레벨(나무 20) | 4단계 + `plant(Entities.Bush)` | `docs/unlocks/plant.md`, `Strings/unlock_tooltips.txt`의 `@unlock_descr_plant` |
| 6 | [`stages/Stage6BushGrid.cs`](stages/Stage6BushGrid.cs) | 5단계 + `expand` 2레벨 | `speed` 2레벨(나무 20), `carrots`(나무 50) | 5단계 + `for i in range(...)`, `get_world_size()`, `East` | `docs/unlocks/expand_2.md`, `docs/scripting/for.md`, `docs/unlocks/expand_1.md` |
| 7 | [`stages/Stage7HayGrid.cs`](stages/Stage7HayGrid.cs) | 6단계와 같음 | `debug`(건초 50 + 나무 50), `operators`(건초 150 + 나무 10) | 6단계에서 `plant` 뺌 | 6단계와 같음 |

대조 근거 문서는 게임 설치 폴더의 `TheFarmerWasReplaced_Data/StreamingAssets/Languages/EN/` 아래에 있습니다. 모든 `.py`의 첫 줄은 `tfwrc`가 넣는 `#` 주석이며, 처음부터 있는 `comments` 해금으로 쓸 수 있습니다.

해금 순서는 게임 해금 트리의 비용과 선행 조건을 따릅니다. 트리 순서가 위 표와 다르면 단계 파일과 표를 그 순서에 맞춥니다.

단계별 주의:

- **1단계**: 반복문이 없어서 한 번 실행하면 나열한 `harvest()` 줄 수만큼만 수확합니다. `loops` 비용만큼 건초가 모일 때까지 F5를 여러 번 누릅니다.
- **2단계**: `speed`를 해금한 뒤에는 쓰지 않습니다. 드론이 풀이 자라는 속도보다 빨리 수확해 수확량이 0이 됩니다(`docs/unlocks/speed.md`). `speed` 뒤에는 3단계를 배치합니다.
- **4단계**: `expand`로 넓어진 땅을 북쪽으로 돌며 다 자란 칸만 수확합니다. 가장자리를 넘으면 반대편으로 돌아옵니다.
- **5단계**: 다 자란 칸을 거둔 자리에 덤불을 심어 나무를 모읍니다. 덤불이 나무를 주는지 확인하려고, 처음 실행해 나무가 생기면 해금하기 전에 한 번 저장(Ctrl+S)합니다.
- **6단계**: `expand` 2레벨로 넓어진 정사각형 농장을 열 단위로 돕니다(북쪽으로 한 바퀴, 동쪽으로 한 칸). 나무는 누적 150이 필요합니다. `speed` 2레벨·`carrots`를 해금한 뒤 `debug`·`operators`용 나무 60이 남았을 때(`save.json`의 `wood` 보유량 기준) 7단계로 넘어갑니다.
- **7단계**: 덤불을 다시 심지 않아, 남은 덤불은 한 번 나무를 주고 풀로 돌아갑니다. 처음 한 바퀴는 건초 수확량이 낮습니다. 건초 200이 모이면 `debug`·`operators`를 해금합니다. 변수와 연산자가 아직 없어 한 스크립트로 칸마다 덤불과 풀을 나눌 수 없으므로, 나무(6단계)와 건초(7단계)를 따로 모읍니다.

## 컴파일·배치

```powershell
pwsh farm/deploy.ps1 -Stage <단계 번호> [-Save <세이브 이름, 기본 Save0>] [-SaveDir <폴더 직접 지정>]
```

- `farm/stages/Stage<단계 번호>*.cs`를 `tfwrc --lang cs --toplevel`로 컴파일합니다(`dotnet run --project src/tfwrc -c Release`). 처음 실행할 때는 빌드 때문에 시간이 걸립니다.
- 결과를 세이브 폴더에 **늘 같은 이름 `main.py`** 로 넣습니다. 세이브 폴더는 기본적으로 `%USERPROFILE%\AppData\LocalLow\TheFarmerWasReplaced\TheFarmerWasReplaced\Saves\<세이브 이름>`입니다(게임 문서 `docs/external_editor.md`).
- `--toplevel`을 쓰는 이유: 기본 출력에는 `def main():`이 들어가는데, `def`는 `functions` 해금 전에는 쓸 수 없습니다.

## 게임에서 하는 일

1. `deploy.ps1`로 첫 단계를 배치합니다. `main.py`가 새로 생기면 게임에서 세이브를 **다시 불러와** `main` 코드 창이 보이게 합니다. 이후 단계는 같은 파일을 덮어쓰므로 File Watcher가 바로 반영합니다.
2. `main` 코드 창에서 실행(F5)합니다. 오류가 나면 실행을 멈추고 오류 내용을 확인합니다.
3. 자원이 모이면 해금 트리에서 다음 해금을 누릅니다.
4. 게임에서 저장(Ctrl+S)합니다. 진행 상태(아이템, 해금)는 세이브 폴더의 `save.json`에 기록됩니다.
5. 다음 단계를 배치하고 2번부터 되풀이합니다. `main.py`가 이미 있으면 세이브를 다시 불러오지 않고 다음 단계를 배치합니다(다시 불러오면 저장하지 않은 진행이 사라질 수 있습니다).
