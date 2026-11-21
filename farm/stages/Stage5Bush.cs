using static TFWR.Api.Game;
using TFWR.Api;

// Stage 5: Plant unlocked. Grow bushes on the 1x3 column to collect wood.
// Only replant a tile right after harvesting it, so growing bushes are left alone.
// Use the wood to unlock Expand level 2.
public static class Stage5Bush
{
    public static void Main()
    {
        while (true)
        {
            if (CanHarvest())
            {
                Harvest();
                Plant(Entities.Bush);
            }
            Move(Direction.North);
        }
    }
}
