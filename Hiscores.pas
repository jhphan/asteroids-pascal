Unit HiScores;

Interface
{=========================================================================}
Procedure ReadScores(FName : String);
Function AddScore(HiScore : Integer) : Integer;
Function GetName : String;
Procedure SaveScores(FName : String);
Procedure DrawScores(Y, TFont, TSize, TC, SFont, SSize, SC: Integer;
                     Title : String);
{=========================================================================}
Implementation
{=========================================================================}
Uses Drivers, Graph;
Type Scre = Record
               Name    : String;
               HiScore : Integer;
            End;
     SFile = File of Scre;
Var Scores    : Array[1 .. 10] of Scre;
    ScoreFile : SFile;
    KEvent    : TEvent;
{-------------------------------------------------------------------------}
Function FileExists : Boolean;
Begin
   FileExists := TRUE;
   {$I-}
   Reset (ScoreFile);
   {$I+}
   If IOResult = 0
      Then
      Else FileExists := FALSE;
End;
{-------------------------------------------------------------------------}
Procedure ResetArray;
Var C : Integer;
Begin
   For C := 1 To 10 Do
    Begin
       Scores[C].Name := '';
       Scores[C].HiScore := 0;
    End;
End;
{-------------------------------------------------------------------------}
Procedure CreateScoreFile(FName : String);
Var C : Integer;
Begin
   ResetArray;
   ReWrite(ScoreFile);
   For C := 1 To 10 Do
    Begin
      Seek(ScoreFile, C);
      Write(ScoreFile, Scores[C]);
    End;
End;
{-------------------------------------------------------------------------}
Procedure ReadFile(FName : String);
Var C : Integer;
Begin
   Reset(ScoreFile);
   For C := 1 To 10 Do
    Begin
      Seek(ScoreFile, C);
      Read(ScoreFile, Scores[C]);
    End;
End;
{-------------------------------------------------------------------------}
Procedure ReadScores(FName : String);
Begin
   Assign(ScoreFile, FName);
   If FileExists = FALSE
      Then CreateScoreFile(FName)
      Else ReadFile(FName);
End;
{-------------------------------------------------------------------------}
Procedure CenterText(Y : Integer; Text : String);
Var X : Integer;
Begin
   X := (GetMaxX Div 2) - (TextWidth(Text) Div 2);
   OutTextXY(X, Y, Text);
End;
{-------------------------------------------------------------------------}
Function GetName : String;
Var N : Integer;
    S : String;
Begin
   S := '';
   N := 0;
   ClearDevice;
   SetTextStyle(TriplexFont, HorizDir, 5);
   SetColor(9);
   CenterText(100, 'Enter your name:');
   SetTextStyle(SansSerifFont, HorizDir, 3);
   SetColor(10);
   SetFillStyle(SolidFill, 0);
   Repeat
      GetKeyEvent(KEvent);
      If KEvent.What = evKeyDown Then
       Begin
         If KEvent.ScanCode = 14 Then
          Begin
            If Length(S) > 0 Then
             Begin
               Delete(S, Length(S), 1);
               Bar(0, 200, 639, 300);
               CenterText(200, S);
               N := N - 1;
             End;
          End
         Else
          Begin
            If N < 10 Then
             Begin
               S := S + KEvent.CharCode;
               Bar(0, 200, 639, 300);
               CenterText(200, S);
               N := N + 1;
               KEvent.What := evNothing;
             End;
          End;
       End;
   Until (KEvent.ScanCode = 28) And (Length(S) > 0);
   GetName := S;
   ClearDevice;
End;
{-------------------------------------------------------------------------}
Function AddScore(HiScore : Integer) : Integer;
Var Place, C : Integer;
Begin
   Place := 0;
   For C := 10 DownTo 1 Do
      If HiScore > Scores[C].HiScore Then Place := C;
   AddScore := Place;
   If Place > 0 then
    Begin
      For C := 10 DownTo Place + 1 Do
         Scores[C] := Scores[C - 1];
      Scores[Place].Name := GetName;
      Scores[Place].HiScore := HiScore;
      AddScore := Place;
    End;
End;
{-------------------------------------------------------------------------}
Procedure SaveScores(FName : String);
Var C : Integer;
Begin
   Assign(ScoreFile, FName);
   ReWrite(ScoreFile);
   For C := 1 To 10 Do
    Begin
      Seek(ScoreFile, C);
      Write(ScoreFile, Scores[C]);
    End;
   Close(ScoreFile);
End;
{-------------------------------------------------------------------------}
Procedure DrawScores(Y, TFont, TSize, TC, SFont, SSize, SC: Integer;
                     Title : String);
Var C, CY : Integer;
    S, S1 : String;
Begin
   SetTextStyle(TFont, HorizDir, TSize);
   SetColor(TC);
   CenterText(Y, Title);
   CY := Y + TextHeight(Title) + 10;
   SetTextStyle(SFont, HorizDir, SSize);
   SetColor(SC);
   For C := 1 To 10 Do
    Begin
      Str(C, S);
      Str(Scores[C].HiScore, S1);
      S := S + '.';
      S := S + Scores[C].Name + '.....' + S1;
      CenterText(CY, S);
      CY := CY + TextHeight(Scores[C].Name);
    End;
End;
{=========================================================================}
End.