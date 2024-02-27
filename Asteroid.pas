Program Asteroid;
Uses
   Graph,
   Crt,
   Bitmap,
   HiScores,
   Menus,
   Drivers;
{=========================================================================}
Type CoordType = Array[1 .. 2] of Integer;
Const
   HiScoreFile = 'Asteroid.Scr';
   kLeft = 75;
   kRight = 77;
   kDown = 80;
   kUp = 72;
   kEsc = 1;
   kHelp = 59;
   kNew = 60;
   kPause = 61;
   kSpace = 57;
   BkSpc = 14;
   Enter = 28;
   kFire = 53;
   MaxSpeed = 10;
   MaxBullets = 4;
   MaxLife = 40;
   BulletSpeed = 10;
   MaxAsteroids = 10;
   DelaySpeed = 15;
   RotateInterval = 5;
   LAstSize = 50;
   LAstHalf = 25;
   SAstSize = 25;
   SAstHalf = 12;
   BulletSize = 0;
   MaxLAstSpeed = 5;
   MaxSAstSpeed = 5;
   LargeScore = 100;
   SmallScore = 200;
   mNew = 1;
   mScores = 2;
   mAbout = 3;
   mHelp = 4;
   mExit = 5;
   Pi = 3.1415926;
   ShipCoords : Array[1 .. 4] of
      CoordType = ((0, -7), (6, 7), (0, 5), (-6, 7));
   ShipWidth = 12;
   ShipHeight = 14;
{=========================================================================}
Type
ShipType =
 Record
   Angle,
   Direction,
   Ships     : Integer;
   X, Y,
   Speed     : Real;
   Active,
   Accel     : Boolean;
 End;
BulletType =
 Record
   Active    : Boolean;
   X, Y      : Real;
   Life,
   Direction : Integer;
 End;
AsteroidType =
 Record
   Active    : Boolean;
   X, Y,
   Speed,
   Direction : Integer;
 End;
{=========================================================================}
Var
   LAst,
   SAst          : Pointer;
   Ship          : ShipType;
   Bullet        : Array[1 .. MaxBullets] of BulletType;
   LargeAst      : Array[1 .. MaxAsteroids] of AsteroidType;
   SmallAst      : Array[1 .. MaxAsteroids * 2] of AsteroidType;
   CCoords       : Array[1 .. 4] of CoordType;
   KEvent        : TEvent;
   Score         : Integer;
   Menu          : MenuType;
{=========================================================================}
Procedure InitGraphics;
Var D, M : Integer;
Begin
   D := Detect;
   InitGraph(D, M, '');
End;
{=========================================================================}
Procedure LoadPics;
Begin
   LAst := GetPic('last.pic');
   SAst := GetPic('sast.pic');
End;
{=========================================================================}
Procedure InitMenu;
Begin
   SetMenu(Menu, 'Asteroids', 100, 9, 12, 10, GothicFont, TriplexFont,
           8, 4, 1, 5);
   SetMItem(Menu, mNew, 'Start Game');
   SetMItem(Menu, mScores, 'High Scores');
   SetMItem(Menu, mAbout, 'About Asteroids');
   SetMItem(Menu, mHelp, 'Help Me!');
   SetMItem(Menu, mExit, 'I Quit!');
End;
{=========================================================================}
Procedure ShutDown;
Begin
   ClearDevice;
   CloseGraph;
   SaveScores(HiScoreFile);
   Halt;
End;
{=========================================================================}
Function AsteroidsLeft : Boolean;
Var
   Count : Integer;
   Yes   : Boolean;
Begin
   Yes := FALSE;
   For Count := 1 To MaxAsteroids Do
      If LargeAst[Count].Active = TRUE Then Yes := TRUE;
   For Count := 1 To MaxAsteroids * 2 Do
      If SmallAst[Count].Active = TRUE Then Yes := TRUE;
   AsteroidsLeft := Yes;
End;
{=========================================================================}
Procedure ResetBullets;
Var
   Count : Integer;
Begin
   For Count := 1 To MaxBullets Do
    Bullet[Count].Active := FALSE;
End;
{=========================================================================}
Procedure ResetAsteroids;
Var
   Count : Integer;
Begin
   For Count := 1 To MaxAsteroids Do
      LargeAst[Count].Active := FALSE;
   For Count := 1 To MaxAsteroids * 2 Do
      SmallAst[Count].Active := FALSE;
End;
{=========================================================================}
Procedure SetDefaultVars;
Begin
   ResetBullets;
   Score := 0;
   With Ship Do
    Begin
      X := 320;
      Y := 240;
      Angle := 0;
      Direction := 0;
      Speed := 0;
      Accel := FALSE;
      Ships := 5;
    End;
End;
{=========================================================================}
Procedure SetRandomAsteroids(Level : Integer);
Var
   Count,
   cX, cY,
   sDivide : Integer;
Begin
   sDivide := GetMaxY Div 5;
   cX := 0;
   cY := Round(Random(GetMaxY));
   For Count := 1 To Level Do
    Begin
      With LargeAst[Count] Do
       Begin
         X := cX;
         Y := cY;
         Active := TRUE;
         Speed := Random(MaxLAstSpeed) + 1;
         Direction := Round(Random(360));
       End;
      cY := Round(Random(GetMaxY));
    End;
End;
{=========================================================================}
Procedure EraseAsteroid(Num : Integer; Large : Boolean);
Var
   X, Y : Real;
Begin
   SetFillStyle(SolidFill, 0);
   If Large = TRUE Then
    Begin
      X := LargeAst[Num].X;
      Y := LargeAst[Num].Y;
      Bar(Round(X - (LAstHalf)), Round(Y - (LAstHalf)),
          Round(X + (LAstHalf)), Round(Y + (LAstHalf)));
    End
   Else
    Begin
      X := SmallAst[Num].X;
      Y := SmallAst[Num].Y;
      Bar(Round(X - (SAstHalf)), Round(Y - (SAstHalf)),
          Round(X + (SAstHalf)), Round(Y + (SAstHalf)));
    End;
End;
{=========================================================================}
Procedure DrawAsteroids(Draw : Boolean);
Var
   Count : Integer;
Begin
   { Draw Large }
   For Count := 1 To MaxAsteroids Do
    Begin
      With LargeAst[Count] Do
       Begin
         If Active = TRUE Then
          Begin
            If Draw = TRUE
              Then PutImage(Round(X - (LAstHalf)), Round(Y - (LAstHalf)), LAst^, CopyPut)
              Else EraseAsteroid(Count, TRUE);
          End;
       End;
    End;
    { Draw Small }
   For Count := 1 To MaxAsteroids * 2 Do
    Begin
      With SmallAst[Count] Do
       Begin
         If Active = TRUE Then
          Begin
            If Draw = TRUE
              Then PutImage(Round(X - (SAstHalf)), Round(Y - (SAstHalf)), SAst^, CopyPut)
              Else EraseAsteroid(Count, FALSE);
          End;
       End;
    End;
End;
{=========================================================================}
Procedure MoveAsteroids;
Var
   Count : Integer;
   Rad   : Real;
Begin
   { Move Large }
   For Count := 1 To MaxAsteroids Do
    Begin
      With LargeAst[Count] Do
       Begin
         If Active = TRUE Then
          Begin
            Rad := Direction * (pi / 180);
            X := Round(X + Speed * Sin(Rad));
            Y := Round(Y + Speed * -Cos(Rad));
            If X < LAstHalf Then X := GetMaxX - LAstHalf;
            If X > GetMaxX - LAstHalf Then X := LAstHalf;
            If Y < LAstHalf Then Y := GetMaxY - LAstHalf;
            If Y > GetMaxY - LAstHalf Then Y := LAstHalf;
          End;
       End;
    End;
   { Move Small }
   For Count := 1 To MaxAsteroids * 2 Do
    Begin
      With SmallAst[Count] Do
       Begin
         If Active = TRUE Then
          Begin
            Rad := Direction * (pi / 180);
            X := Round(X + Speed * Sin(Rad));
            Y := Round(Y + Speed * -Cos(Rad));
            If X < SAstHalf Then X := GetMaxX - SAstHalf;
            If X > GetMaxX - SAstHalf Then X := SAstHalf;
            If Y < SAstHalf Then Y := GetMaxY - SAstHalf;
            If Y > GetMaxY - SAstHalf Then Y := SAstHalf;
          End;
       End;
    End;
End;
{=========================================================================}
Procedure DrawShip(Color : Integer);
Var X, Y,
    Count       : Integer;
Begin
   X := Round(Ship.X);
   Y := Round(Ship.Y);
   SetColor(Color);
   MoveTo(X + CCoords[1][1], Y + CCoords[1][2]);
   LineTo(X + CCoords[2][1], Y + CCoords[2][2]);
   LineTo(X + CCoords[3][1], Y + CCoords[3][2]);
   LineTo(X + CCoords[4][1], Y + CCoords[4][2]);
   LineTo(X + CCoords[1][1], Y + CCoords[1][2]);
End;
{=========================================================================}
Procedure RotateShipCoords;
Var
   Count,
   Angle,
   NX, NY : Integer;
   Rad    : Real;
Begin
   Angle := Ship.Angle;
   Rad := Angle * (pi / 180);
   For Count := 1 To 4 Do
    Begin
      CCoords[Count][1] := Round(ShipCoords[Count][1] * Cos(Rad) - ShipCoords[Count][2] * Sin(Rad));
      CCoords[Count][2] := Round(ShipCoords[Count][1] * Sin(Rad) + ShipCoords[Count][2] * Cos(Rad));
    End;
End;
{=========================================================================}
Procedure RotateShip(Right : Boolean);
Begin
   If Right = TRUE Then
    Begin
      Ship.Angle := Ship.Angle + RotateInterval;
      If Ship.Angle >= 360 Then Ship.Angle := Ship.Angle - 360;
    End
   Else
    Begin
      Ship.Angle := Ship.Angle - RotateInterval;
      If Ship.Angle < 0 Then Ship.Angle := 360 + Ship.Angle;
    End;
   RotateShipCoords;
End;
{=========================================================================}
Procedure AccelShip;
Begin
   Ship.Speed := Ship.Speed + 0.3;
   If Ship.Speed >= MaxSpeed Then Ship.Speed := MaxSpeed;
End;
{=========================================================================}
Procedure SlowShip;
Begin
   If Ship.Speed > 0 Then Ship.Speed := Ship.Speed - 0.05;
End;
{=========================================================================}
Procedure MoveShip;
Var
   Rad : Real;
Begin
   If Ship.Speed > 0 Then
    Begin
      Rad := Ship.Direction * (pi / 180);
      Ship.X := Ship.X + Ship.Speed * Sin(Rad);
      Ship.Y := Ship.Y + Ship.Speed * -Cos(Rad);
      If Ship.X < 0 Then Ship.X := GetMaxX;
      If Ship.X > GetMaxX Then Ship.X := 0;
      If Ship.Y < 0 Then Ship.Y := GetMaxY;
      If Ship.Y > GetMaxY Then Ship.Y := 0;
    End;
End;
{=========================================================================}
Procedure DrawBullets(Color : Byte);
Var
   Count : Byte;
Begin
   For Count := 1 To MaxBullets Do
      If Bullet[Count].Active = TRUE Then
       Begin
         SetColor(Color);
         Circle(Round(Bullet[Count].X), Round(Bullet[Count].Y), BulletSize);
       End;
End;
{=========================================================================}
Function InObject(X, Y, W, H, oX, oY, oW, oH : Integer) : Boolean;
Begin
   InObject := FALSE;
   If (((X > oX - (oW Div 2) - (W Div 2)) And (X < oX + (oW Div 2) + (W Div 2)))
      And ((Y > oY - (oH Div 2) - (H Div 2)) And (Y < oY + (oH Div 2) + (H Div 2))))
      Then InObject := TRUE;
End;
{=========================================================================}
Procedure AddToScore(Add : Integer);
Begin
   Score := Score + Add;
End;
{=========================================================================}
Procedure InitSmallAsteroids(Num : Integer);
Var
   Count : Byte;
Begin
   For Count := 1 DownTo 0 Do
    Begin
      With SmallAst[(Num * 2) - Count] Do
       Begin
         X := LargeAst[Num].X;
         Y := LargeAst[Num].Y;
         Speed := Round(Random(MaxSAstSpeed)) + 1;
         Direction := Round(Random(360));
         Active := TRUE;
       End;
     End;
End;
{=========================================================================}
Procedure DestroyLargeAsteroid(iAsteroid, iBullet : Integer);
Begin
   LargeAst[iAsteroid].Active := FALSE;
   InitSmallAsteroids(iAsteroid);
   Bullet[iBullet].Active := FALSE;
   EraseAsteroid(iAsteroid, TRUE);
   AddToScore(LargeScore);
End;
{=========================================================================}
Procedure DestroySmallAsteroid(iAsteroid, iBullet : Integer);
Begin
   SmallAst[iAsteroid].Active := FALSE;
   Bullet[iBullet].Active := FALSE;
   EraseAsteroid(iAsteroid, FALSE);
   AddToScore(SmallScore);
End;
{=========================================================================}
Procedure CheckBulletCollisions(Num : Integer);
Var
   Count : Integer;
Begin
   { Large }
   For Count := 1 To MaxAsteroids Do
    Begin
      If LargeAst[Count].Active = TRUE Then
       Begin
         If InObject(Round(Bullet[Num].X), Round(Bullet[Num].Y), 0, 0,
            LargeAst[Count].X, LargeAst[Count].Y, LAstSize, LAstSize) = TRUE
            Then DestroyLargeAsteroid(Count, Num);
       End;
    End;
   { Small }
   For Count := 1 To MaxAsteroids * 2 Do
    Begin
      If SmallAst[Count].Active = TRUE Then
       Begin
         If InObject(Round(Bullet[Num].X), Round(Bullet[Num].Y), 0, 0,
            SmallAst[Count].X, SmallAst[Count].Y, SAstSize, SAstSize) = TRUE
            Then DestroySmallAsteroid(Count, Num);
       End;
    End;
End;
{=========================================================================}
Procedure MoveBullets;
Var
   aCount,
   Count  : Byte;
   Rad    : Real;
Begin
   For Count := 1 To MaxBullets Do
      If Bullet[Count].Active = TRUE Then
       Begin
         With Bullet[Count] Do
          Begin
            Rad := Direction * (Pi / 180);
            X := X + BulletSpeed * Sin(Rad);
            Y := Y + BulletSpeed * -Cos(Rad);
            If X < 0 Then X := GetMaxX;
            If X > GetMaxX Then X := 0;
            If Y < 0 Then Y := GetMaxY;
            If Y > GetMaxY Then Y := 0;
            CheckBulletCollisions(Count);
            Life := Life + 1;
            If Life > MaxLife Then Active := FALSE;
          End;
       End;
End;
{=========================================================================}
Procedure Fire;
Var
   Count : Byte;
Begin
   For Count := 1 To MaxBullets Do
    Begin
      If Bullet[Count].Active = FALSE Then
       Begin
         With Bullet[Count] Do
          Begin
            Active := TRUE;
            X := Ship.X;
            Y := Ship.Y;
            Direction := Ship.Angle;
            Life := 0;
            Exit;
          End;  { With }
       End;  { If }
    End;
End;
{=========================================================================}
Function CheckShipCollision : Boolean;
Var
   Count : Integer;
   Yes   : Boolean;
Begin
   Yes := FALSE;
   For Count := 1 To MaxAsteroids Do
    Begin
      If LargeAst[Count].Active = TRUE Then
       Begin
         If InObject(Round(Ship.X), Round(Ship.Y), ShipWidth, ShipHeight,
            LargeAst[Count].X, LargeAst[Count].Y, LAstSize, LAstSize) = TRUE
            Then Yes := TRUE;
       End;
    End;
   For Count := 1 To MaxAsteroids * 2 Do
    Begin
      If SmallAst[Count].Active = TRUE Then
       Begin
         If InObject(Round(Ship.X), Round(Ship.Y), ShipWidth, ShipHeight,
            SmallAst[Count].X, SmallAst[Count].Y, SAstSize, SAstSize) = TRUE
            Then Yes := TRUE
       End;
    End;
   CheckShipCollision := Yes;
End;
{=========================================================================}
Function DestroyShip : Integer;
Begin
   Ship.Active := FALSE;
   Ship.Ships := Ship.Ships - 1;
   DestroyShip := Ship.Ships;
End;
{=========================================================================}
Procedure ShowScores;
Begin
   ClearDevice;
   DrawScores(50, SansSerifFont, 6, 10, TriplexFont, 3, 5,
              'High Scores');
   Readln;
   ClearDevice;
End;
{=========================================================================}
Procedure CenterText(Y : Integer; Text : String; Vert : Boolean);
Var X : Integer;
Begin
   If Vert = FALSE
      Then X := (GetMaxX Div 2) - (TextWidth(Text) Div 2)
      Else X := (GetMaxX Div 2) - (TextHeight(Text) Div 2);
   OutTextXY(X, Y, Text);
End;
{=========================================================================}
Procedure DoScore;
Var
   Place : Integer;
   S2, S : String;
Begin
   ClearDevice;
   SetTextStyle(TriplexFont, HorizDir, 4);
   Str(Score, S);
   SetColor(12);
   CenterText(100, 'You have a score of:', FALSE );
   CenterText(150, S, FALSE);
   Readln;
   ClearDevice;
   Place := AddScore(Score);
   If Place > 0 Then ShowScores;
End;
{=========================================================================}
Procedure DrawBackGround;
Var Count,
    Color : Integer;
Begin
   SetTextStyle(TriplexFont, VertDir, 4);
   For Color := 7 To 8 Do
    Begin
      SetColor(Color);
      For Count := 0 To 20 Do
         OutTextXY(Count * 30, 0, 'Asteroids! Asteroids! Asteroids!');
    End;
End;
{=========================================================================}
Procedure HelpMe;
Begin
   ClearDevice;
   DrawBackGround;
   SetTextStyle(TriplexFont, HorizDir, 4);
   SetColor(9);
   CenterText(40, '<Right/Left Shift> - Rotate', FALSE);
   SetColor(10);
   CenterText(90, '<Enter>, ''/'', <Space> - Fire', FALSE);
   SetColor(11);
   CenterText(140, '<Ctrl> - Move ship', FALSE);
   SetColor(12);
   CenterText(190, '<F1> - This help screen', FALSE);
   SetColor(13);
   CenterText(240, '<F3> - Pause/Unpause', FALSE);
   SetColor(14);
   CenterText(290, '<Esc> - Quit game', FALSE);
   SetTextStyle(SansSerifFont, HorizDir, 1);
   SetColor(3);
   CenterText(430, 'Press <Enter> to continue', FALSE);
   Readln;
   ClearDevice;
End;
{=========================================================================}
Procedure AboutAsteroids;
Begin
   ClearDevice;
   DrawBackGround;
   SetTextStyle(GothicFont, HorizDir, 9);
   SetColor(10);
   CenterText(50, 'Asteroids', FALSE);
   SetTextStyle(TriplexFont, HorizDir, 3);
   SetColor(12);
   CenterText(200, 'Programming III  1997', FALSE);
   CenterText(225, 'Westmoore High School', FALSE);
   SetTextStyle(TriplexFont, HorizDir, 1);
   SetColor(11);
   CenterText(275, 'Programming Team:', FALSE);
   CenterText(300, 'John Phan', FALSE);
   Readln;
   ClearDevice;
End;
{=========================================================================}
Procedure PauseGame;
Begin
   Repeat
      GetKeyEvent(KEvent);
   Until KEvent.What = evKeyDown;
End;
{=========================================================================}
Function HandleKeyDown(Key : Byte) : Boolean;
Var Quit : Boolean;
Begin
   Quit := FALSE;
   If (Key = Enter) Or (Key = kFire) or (Key = kSpace) Then Fire
   Else If Key = kHelp Then HelpMe
   Else If Key = kPause Then PauseGame
   Else If Key = kEsc Then Quit := TRUE;
   HandleKeyDown := Quit;
End;
{=========================================================================}
Procedure HandleShipMovement;
Begin
   If GetShiftState And kbRightShift <> 0 Then RotateShip(TRUE);
   If GetShiftState And kbLeftShift <> 0 Then RotateShip(FALSE);
   If GetShiftState And kbCtrlShift <> 0 Then
    Begin
      If Ship.Speed > 0 Then
      If Ship.Direction <> Ship.Angle Then Ship.Speed := 0;
      Ship.Accel := TRUE;
      Ship.Direction := Ship.Angle;
    End;
End;
{=========================================================================}
Procedure PlayGame;
Var
   Level : Integer;
   Dead  : Boolean;
Begin
   ClearDevice;
   Level := 1;
   Ship.Ships := 5;
   ResetAsteroids;
   SetRandomAsteroids(Level);
   Dead := FALSE;
   Repeat
      DrawShip(0);
      DrawBullets(0);
      If Ship.Accel = TRUE
         Then AccelShip
         Else SlowShip;
      MoveShip;
      MoveBullets;
      Ship.Accel := FALSE;
      GetKeyEvent(KEvent);
      If KEvent.What = evKeyDown Then
         If HandleKeyDown(KEvent.ScanCode) = TRUE Then Dead := TRUE;
      HandleShipMovement;
      If CheckShipCollision = TRUE Then
       Begin
         If Ship.Active = TRUE Then
            If DestroyShip = 0 Then Dead := TRUE;
       End
      Else
       Begin
         If Ship.Active = TRUE
            Then DrawShip(10 + Ship.Ships)
            Else Ship.Active := TRUE;
       End;
      DrawBullets(15);
      DrawAsteroids(FALSE);
      MoveAsteroids;
      DrawAsteroids(TRUE);
      If AsteroidsLeft = FALSE Then
       Begin
         If Level < MaxAsteroids Then Level := Level + 1;
         SetRandomAsteroids(Level);
       End;
      Delay(DelaySpeed);
   Until (Dead = TRUE);
End;
{=========================================================================}
Procedure HandleOption(Option : Integer);
Begin
   Case Option of
   mNew:
    Begin
      SetDefaultVars;
      RotateShipCoords;
      PlayGame;
      DoScore;
      ClearDevice;
    End;
   mScores:
      ShowScores;
   mHelp:
      HelpMe;
   mAbout:
      AboutAsteroids;
   mExit:
      ShutDown;
   End;
End;
{=========================================================================}
Procedure DoMenu;
Var Exit : Boolean;
Begin
   Exit := FALSE;
   DrawMenu(Menu);
   Repeat
      GetKeyEvent(KEvent);
      If KEvent.What = evKeyDown Then
       Begin
         If KEvent.ScanCode = kDown Then MoveMenu(Menu, 1)
         Else If KEvent.ScanCode = kUp Then MoveMenu(Menu, 0)
         Else If KEvent.ScanCode = Enter Then HandleOption(GetCurPlace(Menu));
         DrawMenu(Menu);
       End;
   Until Exit = TRUE;
End;
{=========================================================================}
Begin
   { Initialization }
   Randomize;
   InitGraphics;
   LoadPics;
   InitMenu;
   ReadScores(HiScoreFile);

   DoMenu;
End.