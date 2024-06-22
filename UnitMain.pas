unit UnitMain;

{$mode delphiunicode}

interface

uses
  Classes, Types, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Math, BitmapPixels;

{$define Variant1}

const
  DefaultWidth = 800;
  DefaultHeight = 800;
  ExpectedFps = 25;
  Speed = 0.0003;
  FadeValue = 6;
  Scale = 1;

type

  { TFormMain }

  TFormMain = class(TForm)
    PaintBox: TPaintBox;
    StatusBar: TStatusBar;
    Timer: TTimer;
    TimerFps: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure TimerFpsTimer(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    FBitmap: TBitmap;
    FFps: Integer;
    FTime: Double;
    procedure DrawGalaxy(const Data: TBitmapData);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.FormShow(Sender: TObject);
begin
  ClientWidth := DefaultWidth * Scale;
  ClientHeight := DefaultHeight * Scale + StatusBar.Height;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // make buffer
  FBitmap := TBitmap.Create();

  FTime := 1.0;

  Timer.Interval := 1000 div ExpectedFps;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  // free buffer
  FBitmap.Free();
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  TimerFpsTimer(nil);
end;

procedure TFormMain.PaintBoxPaint(Sender: TObject);
var
  Data: TBitmapData;
  ScaledSize: TSize;
begin
  // calc scaled size
  ScaledSize.Width := PaintBox.Width div Scale;
  ScaledSize.Height := PaintBox.Height div Scale;

  // resize buffer if need
  if (ScaledSize.Width <> FBitmap.Width) or (ScaledSize.Height <> FBitmap.Height) then
  begin
    FBitmap.FreeImage();
  	FBitmap.SetSize(ScaledSize.Width, ScaledSize.Height);
  end;

  // map pixel data
  Data.Map(FBitmap, TAccessMode.ReadWrite, True, clBlack);
  try
    // draw effect
    DrawGalaxy(Data);
    Inc(FFps);
  finally
    // unmap pixeldata
    Data.Unmap();
  end;

  // draw to screen
  PaintBox.Canvas.StretchDraw(
    Rect(0, 0, (PaintBox.Width div Scale) * Scale, (PaintBox.Height div Scale) * Scale),
    FBitmap
  );
end;

procedure TFormMain.TimerFpsTimer(Sender: TObject);
begin
  StatusBar.Panels[0].Text := 'FPS: ' + IntToStr(FFps);
  StatusBar.Panels[1].Text := 'Width: ' + IntToStr(FBitmap.Width);
  StatusBar.Panels[2].Text := 'Height: ' + IntToStr(FBitmap.Height);
  StatusBar.Panels[3].Text := 'Expected FPS: ' + IntToStr(ExpectedFps);

  // timer fps correction
  if FFps < ExpectedFps then
    Timer.Interval := Max(1, Timer.Interval - 10);
  if FFps - 10 > ExpectedFps then
    Timer.Interval := Min(1000, Timer.Interval + 10);

  FFps := 0;
end;

procedure TFormMain.TimerTimer(Sender: TObject);
begin
  PaintBox.Refresh();
end;

procedure TFormMain.DrawGalaxy(const Data: TBitmapData);
var
  ScreenX, ScreenY: Integer;
  I, J: Integer;
  X, Y: Double;
  Pixel, NewPixel: TPixelRec;
begin
  // fade
  for ScreenY := 0 to Data.Height - 1 do
  begin
    for ScreenX := 0 to Data.Width - 1 do
    begin
      Pixel := Data.GetPixelUnsafe(ScreenX, ScreenY);
      Pixel.R := Max(0, Pixel.R - FadeValue);
      Pixel.G := Max(0, Pixel.G - FadeValue);
      Pixel.B := Max(0, Pixel.B - FadeValue);
      Data.SetPixelUnsafe(ScreenX, ScreenY, Pixel);
    end;
  end;

  // draw
  for I := 1 to 150 do
  begin
    X := Random();
    Y := Random();
    NewPixel.R := Random(150);
    NewPixel.G := Random(140);
    NewPixel.B := Random(256);

    for J := 1 to 2000 do
    begin
      {$ifdef Variant1}
      X := Frac(FTime + X + Cos(Y * 2.2 + X * 0.1));
      Y := Frac(FTime * 0.3 + Y + Sin(X * 1.5));
      {$else}
      // variant 2
      X := Frac(FTime + X + Cos(Y * 2.2 + X * 0.1));
      Y := Frac(FTime * 0.3 + Y + Sin(X * 1.5) - 0.5 * Sin(Y * 0.232 + X * 0.14));
      {$endif}

      // calc screen coord
      ScreenX := Trunc(X * Data.Width);
      ScreenY := Trunc(Y * Data.Height);

      // check coord
      if (ScreenX < 0) or (ScreenX >= Data.Width) or (ScreenY < 0) or (ScreenY >= Data.Height) then
        continue;

      // blend pixel
      Pixel := Data.GetPixelUnsafe(ScreenX, ScreenY);
      Pixel.R := Min(255, Pixel.R + NewPixel.R);
      Pixel.G := Min(255, Pixel.G + NewPixel.G);
      Pixel.B := Min(255, Pixel.B + NewPixel.B);
      Data.SetPixel(ScreenX, ScreenY, Pixel);
    end;
  end;

  FTime := FTime + Speed;
end;

end.

