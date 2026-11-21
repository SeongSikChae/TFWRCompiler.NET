using static TFWR.Api.Game;

// Stage 1: fresh save, nothing but harvest() is available.
// No loops yet, so the harvests are listed one by one.
// Run it repeatedly (F5) until there is enough hay to unlock Loops.
public static class Stage1Hay
{
    public static void Main()
    {
        Harvest();
        Harvest();
        Harvest();
        Harvest();
        Harvest();
        Harvest();
        Harvest();
        Harvest();
        Harvest();
        Harvest();
    }
}
