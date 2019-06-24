unit MD.Buttons;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Graphics, FMX.Objects, System.Types, System.UITypes, System.Math, FMX.Ani,
  FMX.FontGlyphs, System.Rtti, FMX.Consts, Threading, MD.ColorPalette, MD.Opacitys, FMX.Layouts, MD.ColorListBox, FMX.Colors,
  FMX.TextLayout, System.Math.Vectors, FMX.Platform;

type
  TMaterialTextSettings = class(TTextSettings)
  private
    FMaterialColor: TMaterialColor;
    function GetMaterialColor: TMaterialColor;
    procedure SetMaterialColor(const Value: TMaterialColor);
  public
    constructor Create(const AOwner: TPersistent); override;
  published
    property Font;
    property MaterialColor: TMaterialColor read GetMaterialColor write SetMaterialColor;
    property Trimming default TTextTrimming.None;
    property WordWrap default True;
    property HorzAlign default TTextAlign.Center;
    property VertAlign default TTextAlign.Center;
  end;

type
  TMDCustomButton = class(TControl)
  private
    { Private declarations }
    FText: TText;
    FMaterialColor: TMaterialColor;
    FFill: TBrush;
    FBackgroundFocus: TCircle;
    FBackgroundFocused: TRectangle;
    FBackgroundPressed: TRectangle;
    FMaterialTextSettings: TTextSettings;
    procedure SetText(const Value: string);
    function GetText: string;
    procedure SetTextSettings(const Value: TTextSettings);
    function GetTextSettings: TTextSettings;

    function GetMaterialColor: TMaterialColor; virtual;
    procedure SetMaterialColor(const Value: TMaterialColor); virtual;
    procedure DoAnimationFinish(Sender: TObject);
    function GetFill: TBrush;
    procedure SetFill(const Value: TBrush);
    function GetFocusedColor: TMaterialColor;
    function GetPressedColor: TMaterialColor;
    procedure SetFocusedColor(const Value: TMaterialColor);
    procedure SetPressedColor(const Value: TMaterialColor);
    procedure DoMaterialTextSettingsChanged(Sender: TObject);
  protected
    procedure FillChanged(Sender: TObject); virtual;
    procedure Resize; override;
    procedure Paint; override;
    procedure Painting; override;
    procedure DoPaint; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure PaintCircleButtonEffect(AMaterialColor: TMaterialColor; X, Y: Single); virtual;
    property PressedColor: TMaterialColor read GetPressedColor write SetPressedColor;
    property FocusedColor: TMaterialColor read GetFocusedColor write SetFocusedColor;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Fill: TBrush read GetFill write SetFill;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property ClipParent;
    property CanFocus default True;
    property Cursor;
    property DragMode;
    property EnableDragHighlight;
    property Enabled;
    property Locked;
    property Height;
    property HitTest default True;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TouchTargetExpansion;
    property Visible;
    property Width;
    property TabOrder default -1;
    property TabStop default True;
    { Events }
    property OnPainting;
    property OnPaint;
    property OnResize;
    { Drag and Drop events }
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    { Mouse events }
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;

    property Text: string read GetText write SetText;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property MaterialColor: TMaterialColor read GetMaterialColor write SetMaterialColor;
  end;

type
  TMDRaisedButton = class(TMDCustomButton)
  private

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published

  end;

type
  TMDFlatButton = class(TMDCustomButton)
  private

    { Private declarations }
  protected
    // function GetMaterialColor: TMaterialColor; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure SetMaterialColor(const Value: TMaterialColor); override;
    function GetMaterialColor: TMaterialColor; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property MaterialColor: TMaterialColor read GetMaterialColor write SetMaterialColor;
  end;

implementation

{ TMDCustomButton }

constructor TMDCustomButton.Create(AOwner: TComponent);
var
  LClass: TTextSettingsClass;
begin

  inherited;

  Self.ClipChildren := True;
  // Height := 36;
  // Width := 88;
  // Margins.Left := 8;
  // Margins.Right := 8;
  Self.CanFocus := True;
  Self.TabStop := True;
  Self.HitTest := True;

  FMaterialColor := TMaterialColors.Blue500;
  FFill := TBrush.Create(TBrushKind.None, FMaterialColor);
  FFill.OnChanged := FillChanged;

  FBackgroundFocused := TRectangle.Create(Self);
  with FBackgroundFocused do
  begin
    HitTest := False;
    Locked := True;
    Parent := Self;
    Height := Self.Height;
    Width := Self.Width;
    Position.X := 0;
    Position.Y := 0;
    Align := TAlignLayout.Client;
    // Align := TAlignLayout.None;
    Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];
    Fill.Color := TMaterialColors.Black;
    Opacity := 0.0;
    Stroke.Kind := TBrushKind.None;
    XRadius := 2;
    YRadius := 2;
    SetSubComponent(True);
    Stored := False;
  end;

  FBackgroundPressed := TRectangle.Create(Self);
  with FBackgroundPressed do
  begin
    HitTest := False;
    Locked := True;
    Parent := Self;
    Height := Self.Height;
    Width := Self.Width;
    Position.X := 0;
    Position.Y := 0;
    Align := TAlignLayout.Client;
    Align := TAlignLayout.None;
    Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];
    Fill.Color := TMaterialColors.Black;
    Opacity := 0.0;
    Stroke.Kind := TBrushKind.None;
    XRadius := 2;
    YRadius := 2;
    SetSubComponent(True);
    Stored := False;
  end;

  FBackgroundFocus := TCircle.Create(Self);
  with FBackgroundFocus do
  begin
    HitTest := False;
    Locked := True;
    Parent := Self;
    Height := Self.Height;
    Width := Self.Width;
    Position.X := 0;
    Position.Y := 0;
    Align := TAlignLayout.Client;
    Align := TAlignLayout.None;
    Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];
    Fill.Color := TMaterialColors.White;
    Opacity := 0.0;
    Stroke.Kind := TBrushKind.None;
    SetSubComponent(True);
    Stored := False;
  end;

  FText := TText.Create(Self);
  with FText do
  begin
    Margins.Left := 8;
    Margins.Right := 8;
    HitTest := False;
    Locked := True;
    Parent := Self;
    Align := TAlignLayout.Client;
    Opacity := DARKTEXT_PRIMARY_OPACITY;
    SetSubComponent(True);
    Stored := False;
  end;

  LClass := nil;
  if LClass = nil then
    LClass := TMaterialTextSettings;

  FMaterialTextSettings := LClass.Create(Self);
  FMaterialTextSettings.OnChanged := DoMaterialTextSettingsChanged;
  FMaterialTextSettings.BeginUpdate;
  try
    FMaterialTextSettings.IsAdjustChanged := True;
  finally
    FMaterialTextSettings.EndUpdate;
  end;

end;

destructor TMDCustomButton.Destroy;
begin

  Self.FreeNotification(Self);
  FreeAndNil(FText);
  FreeAndNil(FFill);
  FreeAndNil(FBackgroundFocus);
  FreeAndNil(FBackgroundFocused);
  FreeAndNil(FBackgroundPressed);
  FreeAndNil(FMaterialTextSettings);
  inherited;
end;

procedure TMDCustomButton.DoAnimationFinish(Sender: TObject);
var
  LParent: TCircle;
  LAnimation: TFloatAnimation;
begin
  LParent := TCircle(TAnimation(Sender).Parent);
  LAnimation := TFloatAnimation(Sender);

  FreeAndNil(LAnimation);
  FreeAndNil(LParent);
end;

procedure TMDCustomButton.DoEnter;
begin
  inherited;
  // FBackgroundFocused.StopPropertyAnimation('Opacity');
  if Self.IsFocused then
  begin
     FBackgroundFocused.Opacity := 0.1;
  end;
end;

procedure TMDCustomButton.DoExit;
begin
  inherited;
  // FBackgroundFocused.StopPropertyAnimation('Opacity');
  if not Self.IsFocused then
  begin
     FBackgroundFocused.Opacity := 0;
  end;

end;

procedure TMDCustomButton.DoMaterialTextSettingsChanged(Sender: TObject);
begin
  // if Assigned(FOnChanged) then
  // FOnChanged(Self);
  FText.TextSettings.Assign(FMaterialTextSettings);
end;

procedure TMDCustomButton.DoMouseEnter;
begin
  inherited;
  // FBackgroundFocused.StopPropertyAnimation('Opacity');
  // FBackgroundFocused.AnimateFloat('Opacity', 0.1, 0.5, TAnimationType.In, TInterpolationType.Linear);

  // FBackgroundFocus.StopPropertyAnimation('Opacity');
  // FBackgroundFocus.AnimateFloat('Opacity', 0.2, 0.5, TAnimationType.In, TInterpolationType.Linear);
end;

procedure TMDCustomButton.DoMouseLeave;
begin
  inherited;
  // FBackgroundFocus.StopPropertyAnimation('Opacity');
  // FBackgroundFocus.Opacity := 0;
  // FBackgroundPressed.StopPropertyAnimation('Opacity');
  // FBackgroundPressed.Opacity := 0;
  // FBackgroundFocused.StopPropertyAnimation('Opacity');
  // if not Self.IsFocused then
  // begin
  // FBackgroundFocused.Opacity := 0;
  // end;
end;

procedure TMDCustomButton.DoPaint;
begin
  inherited;
end;

procedure TMDCustomButton.FillChanged(Sender: TObject);
begin
  Repaint;
end;

function TMDCustomButton.GetFill: TBrush;
begin
  Result := FFill;
end;

function TMDCustomButton.GetFocusedColor: TMaterialColor;
begin
  Result := FBackgroundFocused.Fill.Color;
end;

function TMDCustomButton.GetMaterialColor: TMaterialColor;
begin
  Result := FMaterialColor;
end;

function TMDCustomButton.GetPressedColor: TMaterialColor;
begin
  Result := FBackgroundPressed.Fill.Color;
end;

function TMDCustomButton.GetText: string;
begin
  Result := FText.Text;
end;

function TMDCustomButton.GetTextSettings: TTextSettings;
begin
  Result := FMaterialTextSettings;
end;

procedure TMDCustomButton.MouseClick(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
end;

procedure TMDCustomButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  // FBackgroundFocused.StopPropertyAnimation('Opacity');
  // FBackgroundFocused.Opacity := 0;
  // FBackgroundFocus.StopPropertyAnimation('Opacity');
  // FBackgroundFocus.Opacity := 0;
  // FBackgroundPressed.StopPropertyAnimation('Opacity');
  // FBackgroundPressed.AnimateFloat('Opacity', 0.12, 0.2, TAnimationType.InOut, TInterpolationType.Linear);

end;

procedure TMDCustomButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  // FBackgroundPressed.StopPropertyAnimation('Opacity');
  // FBackgroundPressed.Opacity := 0;
  // FBackgroundFocused.StopPropertyAnimation('Opacity');
  // FBackgroundFocus.StopPropertyAnimation('Opacity');
  // if IsMouseOver then
  // begin
  // FBackgroundFocused.AnimateFloat('Opacity', 0.1, 3, TAnimationType.InOut, TInterpolationType.Linear);
  // FBackgroundFocus.AnimateFloat('Opacity', 0.2, 3, TAnimationType.InOut, TInterpolationType.Linear);
  // end;
end;

procedure TMDCustomButton.Paint;
begin
  inherited;
  // Canvas.BeginScene;
  Canvas.FillRect(TRectF.Create(0, 0, Self.Width, Self.Height), 5, 5, [TCorner.BottomLeft, TCorner.BottomRight, TCorner.TopLeft, TCorner.TopRight],
    AbsoluteOpacity, FFill, TCornerType.Round);
  // Canvas.EndScene;
end;

procedure TMDCustomButton.PaintCircleButtonEffect(AMaterialColor: TMaterialColor; X, Y: Single);
var
  Circle: TCircle;
  Animation: TFloatAnimation;
begin
  FBackgroundFocus.StopPropertyAnimation('Opacity');
  FBackgroundFocus.Opacity := 0;

  Circle := TCircle.Create(nil);
  Circle.Parent := Self;

  Animation := TFloatAnimation.Create(nil);
  Animation.Parent := Circle;

  Circle.Fill.Color := AMaterialColor;
  Circle.Stroke.Kind := TBrushKind.None;
  Circle.HitTest := False;
  Circle.Height := 10;
  Circle.Width := 10;
  Circle.Position.X := X - Circle.Width / 2;
  Circle.Position.Y := Y - Circle.Height / 2;
  Circle.Opacity := 0;


  Circle.AnimateFloat('Opacity', 0.2, 0.2, TAnimationType.InOut, TInterpolationType.Linear);
  Circle.AnimateFloat('Height', Self.Width * 2, 0.7, TAnimationType.InOut, TInterpolationType.Linear);
  Circle.AnimateFloat('Width', Self.Width * 2, 0.7, TAnimationType.InOut, TInterpolationType.Linear);

  Circle.AnimateFloat('Position.X', X - Self.Width, 0.7, TAnimationType.InOut, TInterpolationType.Linear);
  Circle.AnimateFloat('Position.Y', Y - Self.Width, 0.7, TAnimationType.InOut, TInterpolationType.Linear);

  Circle.StopPropertyAnimation('Opacity');

  Animation.AnimationType := TAnimationType.InOut;
  Animation.Interpolation := TInterpolationType.Linear;
  Animation.OnFinish := DoAnimationFinish;
  Animation.Duration := 0.8;
  Animation.PropertyName := 'Opacity';
  Animation.StartFromCurrent := True;
  Animation.StopValue := 0;
  Animation.Start;
end;

procedure TMDCustomButton.Painting;
begin
  inherited;
end;

procedure TMDCustomButton.Resize;
begin
  inherited;
  if Assigned(FBackgroundFocus) then
  begin
    with FBackgroundFocus do
    begin
      Height := Self.Width * 0.85;
      Width := Self.Width * 0.85;
      Position.X := Self.Width / 2 - Width / 2;
      Position.Y := Self.Height / 2 - Height / 2;
    end;
  end;

end;

procedure TMDCustomButton.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TMDCustomButton.SetFocusedColor(const Value: TMaterialColor);
begin
  FBackgroundFocused.Fill.Color := Value;
end;

procedure TMDCustomButton.SetMaterialColor(const Value: TMaterialColor);
begin
  FMaterialColor := Value;
  if Assigned(FFill) then
    FFill.Color := FMaterialColor;
end;

procedure TMDCustomButton.SetPressedColor(const Value: TMaterialColor);
begin
  FBackgroundPressed.Fill.Color := Value;
end;

procedure TMDCustomButton.SetText(const Value: string);
begin
  FText.Text := Value;
end;

procedure TMDCustomButton.SetTextSettings(const Value: TTextSettings);
begin
  FText.TextSettings.Assign(Value);
end;

{ TMDRaisedButton }

constructor TMDRaisedButton.Create(AOwner: TComponent);
begin
  inherited;
  FFill.Kind := TBrushKind.Solid;
end;

destructor TMDRaisedButton.Destroy;
begin
  inherited;
end;

procedure TMDRaisedButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  PaintCircleButtonEffect(TMaterialColors.Black, X, Y);
end;

{ TMDFlatButton }

constructor TMDFlatButton.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TMDFlatButton.Destroy;
begin

  inherited;
end;

function TMDFlatButton.GetMaterialColor: TMaterialColor;
begin
  Result := inherited GetMaterialColor;
end;

procedure TMDFlatButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  PaintCircleButtonEffect(GetMaterialColor, X, Y);
end;

procedure TMDFlatButton.SetMaterialColor(const Value: TMaterialColor);
begin
  inherited SetMaterialColor(Value);
  PressedColor := FMaterialColor;
  FocusedColor := FMaterialColor;
end;

{ TMaterialTextSettings }

constructor TMaterialTextSettings.Create(const AOwner: TPersistent);
begin
  inherited;
  FMaterialColor := TMaterialColors.Black;
  Trimming := TTextTrimming.None;
  WordWrap := True;
  HorzAlign := TTextAlign.Center;
  VertAlign := TTextAlign.Center;
  FontColor := FMaterialColor;
end;

function TMaterialTextSettings.GetMaterialColor: TMaterialColor;
begin
  Result := FMaterialColor;
end;

procedure TMaterialTextSettings.SetMaterialColor(const Value: TMaterialColor);
begin
  FMaterialColor := Value;
  FontColor := FMaterialColor;
end;

end.
