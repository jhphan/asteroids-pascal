Unit Bitmap;

Interface
{========}
Type
   PicArray = Array[0 .. 159, 0 .. 159] of Byte;
{-------------------------------------------------}
Function GetPic(FName : String) : Pointer;
Function GetArray(FName : String) : Pointer;
Function GetWidth : Byte;
Function GetHeight : Byte;
{========}
Implementation
{=============}
Uses
   Graph;
Type
   PFile = file of Byte;
   RGBRec = record
      RedVal, GreenVal, BlueVal : Integer;
   end;
Const
   EGAColors : array[0..MaxColors]
      of RGBRec = (
       ( RedVal:$00; GreenVal:$00; BlueVal:$00 ),
       ( RedVal:$00; GreenVal:$00; BlueVal:$fc ),
       ( RedVal:$24; GreenVal:$fc; BlueVal:$24 ),
       ( RedVal:$00; GreenVal:$fc; BlueVal:$fc ),
       ( RedVal:$fc; GreenVal:$14; BlueVal:$14 ),
       ( RedVal:$b0; GreenVal:$00; BlueVal:$fc ),
       ( RedVal:$70; GreenVal:$48; BlueVal:$00 ),
       ( RedVal:$c4; GreenVal:$c4; BlueVal:$c4 ),
       ( RedVal:$34; GreenVal:$34; BlueVal:$34 ),
       ( RedVal:$00; GreenVal:$00; BlueVal:$70 ),
       ( RedVal:$00; GreenVal:$70; BlueVal:$00 ),
       ( RedVal:$00; GreenVal:$70; BlueVal:$70 ),
       ( RedVal:$70; GreenVal:$00; BlueVal:$00 ),
       ( RedVal:$70; GreenVal:$00; BlueVal:$70 ),
       ( RedVal:$fc; GreenVal:$fc; BlueVal:$24 ),
       ( RedVal:$fc; GreenVal:$fc; BlueVal:$fc )
      );
Var PicFile : PFile;
    Width, Height : Byte;
    TPic : Array [0 .. 159, 0 .. 159] of Byte;
{-------------------------------------------------------------------------}
Procedure DrawPic;
Var X, Y : Integer;
Begin
   For X := 0 To Width - 1 Do
    Begin
      For Y := 0 To Height - 1 Do
       Begin
         PutPixel(X, Y, TPic[X, Y]);
       End;
    End;
End;
{-------------------------------------------------------------------------}
Procedure LoadPic(FName : String);
Var X, Y, Rec     : Integer;
Begin
   Assign (PicFile, FName);
   Reset (PicFile);
   Seek (PicFile, 1);
   Read (PicFile, Width);
   Seek (PicFile, 2);
   Read (PicFile, Height);
   Rec := 3;
   For X := 0 To Width - 1 Do
    Begin
      For Y := 0 To Height - 1 Do
       Begin
         Seek(PicFile, Rec);
         Read(PicFile, TPic[X, Y]);
         Rec := Rec + 1;
       End;
    End;
End;
{-------------------------------------------------------------------------}
Function GetWidth : Byte;
Begin
   GetWidth := Width;
End;
{-------------------------------------------------------------------------}
Function GetHeight : Byte;
Begin
   GetHeight := Height;
End;
{-------------------------------------------------------------------------}
Procedure BlackRGB;
Var Count : Integer;
Begin
   For Count := 0 To 15 Do
      With EGAColors[Count] Do
         SetRGBPalette(Count, 0, 0, 0);
End;
{-------------------------------------------------------------------------}
Procedure DefaultRGB;
Var i : Integer;
Begin
   For i := 0 to MaxColors do
      With EGAColors[i] do
         SetRGBPalette(i, RedVal, GreenVal, BlueVal);
End;
{-------------------------------------------------------------------------}
Function GetArray(FName : String) : Pointer;
Var
   TArray : ^PicArray;
   X, Y   : Byte;
Begin
   LoadPic(FName);
   GetMem(TArray, SizeOf(TPic));
   For X := 0 To Width - 1 Do
    Begin
      For Y := 0 To Height - 1 Do
       Begin
         TArray^[X, Y] := TPic[X, Y];
       End;
    End;
   GetArray := TArray;
End;
{-------------------------------------------------------------------------}
Function GetPic(FName : String) : Pointer;
Var PicPlace : Pointer;
Begin
   LoadPic(FName);
   DrawPic;
   GetMem(PicPlace, ImageSize(0, 0, Width - 1, Height - 1));
   GetImage(0, 0, Width - 1, Height - 1, PicPlace^);
   SetFillStyle(SolidFill, 0);
   Bar(0, 0, Width - 1, Height - 1);
   GetPic := PicPlace;
End;

End.