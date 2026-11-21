using static TFWR.Api.Game;
using TFWR.Api;

// Stage 6: Expand level 2 unlocked, which adds for loops, range() and get_world_size().
// Walk the square farm column by column (north around the column, then one step east)
// and grow bushes everywhere to collect wood for Speed 2, Carrots, Debug and Operators.
public static class Stage6BushGrid
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
                    Plant(Entities.Bush);
                }
                Move(Direction.North);
            }
            Move(Direction.East);
        }
    }
}
