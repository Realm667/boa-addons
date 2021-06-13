
class ScoreHandler : StaticEventHandler
{
    const bonusstep = 40000;

    ParsedValue scoredata;
    int BonusAmt[MAXPLAYERS];

    override void OnRegister()
    {
		scoredata = FileReader.Parse("data/ScoreAmounts.txt");
        scoredata = scoredata.Find("Enemies");
    }

    override void WorldThingDied (WorldEvent e)
    {
        color clr = "CC0000";

        let thing = e.Thing;
        let killer = e.Thing.target;

        if (thing && thing.Default.bCountKill && killer && killer.player)
        {
            if (!thing.bFriendly || (Nazi(thing) && Nazi(thing).user_sneakable))
            {
                int amt = GetScoreAmt(thing);

                killer.score += amt;

                if (killer.score >= BonusAmt[killer.PlayerNumber()])
                {
                    if (BonusAmt[killer.PlayerNumber()] > 0)
                    {
                        killer.A_SetMugshotState("Grin");
                        killer.A_StartSound("classic/life", CHAN_VOICE);
                        killer.GiveBody(25);
                        Nazi.SpyGive(killer, "Ammo9mm", 64);
                        Nazi.SpyGive(killer, "CoinItem", 100);

                        clr = "CCAA00";
                    }

                    BonusAmt[killer.PlayerNumber()] += bonusstep;
                }

                thing.A_Face(killer);
                SpawnDigits(thing, amt, "ScoreNumber", clr);
            }
        }
    }

    int GetScoreAmt(Actor mo)
    {
        int score = FileReader.GetInt(scoredata, mo.GetClassName());
        if (!score) { score = max(100, mo.Default.health * 5); } // Fallback for enemies that aren't included in the score data list

        return score;
    }

    void SpawnDigits(Actor origin, int number, Class<Actor> numactor, color clr)
	{
		int digits;
		int temp = number;

		double position;
		double width = 14 * 0.8;
        double velz = 0.8;
        double angle = origin.AngleTo(origin.target);

		while (temp)
		{
			digits++;
			temp /= 10;
		}

		position = width * digits / 2 - width / 2;

		for (int i = 0; i < digits; i++)
		{
			int digit = number % 10;

            Actor mo = Actor.Spawn(numactor, origin.pos + (Actor.RotateVector((0, -position), origin.angle + 180), 10));

			if (mo)
			{
				FlatNumber(mo).value = digit;
                mo.SetShade(clr);
                mo.master = origin;
                mo.vel.z = velz;
			}

			number /= 10;
			position -= width;
		}
	}

    override void RenderUnderlay (RenderEvent e)
    {
        if (screenblocks > 11 || automapactive) { return; }

        let p = players[consoleplayer].mo;

        if (p.FindInventory("CutsceneEnabled")) { return; }

        if (p)
        {
            String score = String.Format("%i", p.score);
            if (!score.length()) { score = "0"; }

            if (screenblocks > 10)
            {
                DrawToHUD.DrawText(score, (108, -70), BigFont, 1.0, 1.0, shade:Font.CR_RED, flags:ZScriptTools.STR_RIGHT);
            }
            else
            {
                DrawToHUD.DrawText(score, (Screen.GetWidth() / 2, 8), BigFont, 1.0, 1.0, shade:Font.CR_RED, flags:ZScriptTools.STR_CENTERED);
            }
        }
    }
}

class ScoreNumber : FlatNumber
{
    Default
    {
        +BRIGHT
        Alpha 1.0;
        StencilColor "CC0000";
        Scale 0.8;
    }

	States
	{
		Spawn:
			FNUM A 60;
        Fade:
            FNUM # 1 A_FadeOut(0.04, FTF_REMOVE);
			Loop;
	}

    override void Tick()
    {
		if (Level.IsFrozen()) { return; }

        if (master && master.target)
        {
            master.A_Face(master.target);
            angle = master.angle;
        }

        Super.Tick();

        offset.z += vel.z;
        Scale *= 1.0025;
    }
}