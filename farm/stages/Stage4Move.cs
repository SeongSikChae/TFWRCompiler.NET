using static TFWR.Api.Game;
using TFWR.Api;

// Stage 4: Expand unlocked, which adds move() and the direction constants.
// Walk north over the larger farm (moving off the edge wraps around)
// and harvest every grown tile.
public static class Stage4Move
{
    public static void Main()
    {
        while (true)
        {
            if (CanHarvest())
            {
                Harvest();
            }
            Move(Direction.North);
        }
    }
}
