using static TFWR.Api.Game;

// Stage 3: Speed unlocked, which also unlocks if and can_harvest().
// Only harvest grown grass so the faster drone keeps getting hay.
public static class Stage3Check
{
    public static void Main()
    {
        while (true)
        {
            if (CanHarvest())
            {
                Harvest();
            }
        }
    }
}
