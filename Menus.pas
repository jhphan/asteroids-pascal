Unit Menus;

Interface
{=========================================================================}
Type
   MenuType = Record
            Title       : String;
            Y,
            TitleColor,
            ItemColor,
            HiLiteColor,
            TitleFont,
            ItemFont,
            TitleSize,
            ItemSize,
            CurPlace,
            NumItems    : Integer;
            Items       : Array [1 .. 10] of String;
         End;
{========================================}
Procedure SetMenu(Var Mnu : MenuType; T : String; iY, TColor, IColor, HLColor,
                  TFont, IFont, TSize, ISize, CPlace, NItems : Integer);
Procedure SetMItem(Var Mnu : MenuType; It : Integer; S : String);
Procedure MoveHome(Var Mnu : MenuType);
Procedure MoveMenu(Var Mnu : MenuType; Dir : Integer);
Procedure DrawMenu(Mnu : MenuType);
Function GetCurPlace(Mnu : MenuType) : Integer;
{=========================================================================}
Implementation
{=========================================================================}
Uses Graph;
{-------------------------------------------------------------------------}
Procedure SetMenu(Var Mnu : MenuType; T : String; iY, TColor, IColor, HLColor,
                  TFont, IFont, TSize, ISize, CPlace, NItems : Integer);
Begin
   With Mnu Do
    Begin
      Title := T;
      Y := iY;
      TitleColor := TColor;
      ItemColor := IColor;
      HiLiteColor := HLColor;
      TitleFont := TFont;
      ItemFont := IFont;
      TitleSize := TSize;
      ItemSize := ISize;
      CurPlace := CPlace;
      NumItems := NItems;
    End;
End;
{-------------------------------------------------------------------------}
Procedure SetMItem(Var Mnu : MenuType; It : Integer; S : String);
Begin
   Mnu.Items[It] := S;
End;
{-------------------------------------------------------------------------}
Procedure MoveHome(Var Mnu : MenuType);
Begin
   Mnu.CurPlace := 1;
End;
{-------------------------------------------------------------------------}
Procedure MoveMenu(Var Mnu : MenuType; Dir : Integer);
Begin
   If Dir = 0 Then
    Begin
      Mnu.CurPlace := Mnu.CurPlace - 1;
      If Mnu.CurPlace = 0 Then Mnu.CurPlace := 1;
    End
   Else If Dir = 1 Then
    Begin
      Mnu.CurPlace := Mnu.CurPlace + 1;
      With Mnu Do If CurPlace > NumItems Then CurPlace := NumItems;
    End;
End;
{-------------------------------------------------------------------------}
Procedure CenterText(Y : Integer; S : String);
Var X : Integer;
Begin
   X := (GetMaxX Div 2) - (TextWidth(S) Div 2);
   OutTextXY(X, Y, S);
End;
{-------------------------------------------------------------------------}
Procedure DrawMenu(Mnu : MenuType);
Var Count, CurY : Integer;
Begin
   With Mnu Do
    Begin
      SetTextStyle(TitleFont, HorizDir, TitleSize);
      SetColor(TitleColor);
      CenterText(Y, Title);
      CurY := Y + TextHeight(Title);
      SetTextStyle(ItemFont, HorizDir, ItemSize);
    End;
   For Count := 1 To Mnu.NumItems Do
    Begin
      With Mnu Do
       Begin
         If Count = CurPlace
            Then SetColor(HiLiteColor)
            Else SetColor(ItemColor);
         CenterText(CurY, Items[Count]);
         CurY := CurY + TextHeight(Items[Count]);
       End;
    End;
End;
{-------------------------------------------------------------------------}
Function GetCurPlace(Mnu : MenuType) : Integer;
Begin
   GetCurPlace := Mnu.CurPlace;
End;
{-------------------------------------------------------------------------}
End.