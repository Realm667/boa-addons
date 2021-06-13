class VampireBoAStatusBar: BoAStatusBar
{
	DynamicValueInterpolator mBloodInterpolator;

	override void NewGame ()
	{
		Super.NewGame();
		mBloodInterpolator.Reset(0);
	}
	
	override void Tick()
	{
		Super.Tick();
		VampireBoAPlayer vampire = VampireBoAPlayer(CPlayer.mo);
		if (vampire) mBloodInterpolator.Update(vampire.tics_since_last_kill);
	}
	
	override void Init()
	{
		Super.Init();
		mBloodInterpolator = DynamicValueInterpolator.Create(0, 1.25, 1, 100);
	}
	
	override void DrawMainBar (double TicFrac)
	{
		Super.DrawMainBar(TicFrac);
		if (!VampireHandler.VampireSpecialSequenceLevel())
		{
			DrawBar("HORZBLDF", "HORZBLDE", 1050 - mBloodInterpolator.GetValue(), 1050, (screen.GetWidth() / 4 - 90, -70), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
		}
	}
}