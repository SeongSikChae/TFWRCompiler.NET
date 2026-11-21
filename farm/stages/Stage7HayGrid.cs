using static TFWR.Api.Game;
using TFWR.Api;

// Stage 7: same walk as stage 6 but without replanting.
// Harvested bushes give their wood once and the tile turns back into grass,
// so the farm switches to hay for Debug and Operators.
public static class Stage7HayGrid
{
    public static void Main()
    {
        while (true)
        {
            for (var i = 0; i < GetWorldSize(); i++)
            {
                if (CanHarvest())
                {
                    Harvest();
                }
                Move(Direction.North);
            }
            Move(Direction.East);
        }
    }
}
