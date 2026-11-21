using static TFWR.Api.Game;

// Stage 2: Loops unlocked. Harvest forever to collect hay for Speed.
// Stop using this stage once Speed is unlocked: the drone then harvests
// faster than the grass grows and the yield drops to zero (docs/unlocks/speed.md).
public static class Stage2Loop
{
    public static void Main()
    {
        while (true)
        {
            Harvest();
        }
    }
}
