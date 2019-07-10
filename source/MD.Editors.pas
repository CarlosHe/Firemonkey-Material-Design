unit MD.Editors;

interface

uses
  FMXVclUtils, FMX.Graphics, VCL.Graphics, DesignEditors, DesignIntf, System.Types, System.Classes, FMX.Forms,
  MD.ColorPalette, FMXEditors, VCLEditors, System.SysUtils, System.UITypes, FMX.Types, FMX.Ani, ToolsAPI, PropInspAPI;

const
  FilmStripMargin: Integer = 2;
  FilmStripWidth: Integer = 12;
  FilmStripHeight: Integer = 13;
  SCreateNewColorAnimation = 'Create New TColorAnimation';
  SCreateNewColorKeyAnimation = 'Create New TColorKeyAnimation';

type
  TMaterialColorProperty = class(TIntegerProperty, ICustomPropertyDrawing,
    ICustomPropertyListDrawing, ICustomPropertyDrawing80, IProperty160)

  private
    FPropertyPath: string;
  protected
    function IsAnimated: Boolean; virtual;
    procedure CreateNewAnimation(AnimationClass: TComponentClass);
    function TextToMaterialColor(const Value: string): TAlphaColor; virtual;
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
    procedure Edit; override;

    { ICustomPropertyListDrawing }
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer);
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
    { ICustomPropertyDrawing }
    procedure PropDrawName(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    { ICustomPropertyDrawing80 }
    function PropDrawNameRect(const ARect: TRect): TRect;
    function PropDrawValueRect(const ARect: TRect): TRect;
    { IProperty160 }
    procedure SetPropertyPath(const Value: string);

  end;

var
  VCLBitmap: VCL.Graphics.TBitmap = nil;
  FMXBitmap: FMX.Graphics.TBitmap = nil;

implementation

function GetPropertyName(const AnAnimation: TAnimation): string;
begin
  Result := AnsiString('');

  if AnAnimation is TFloatAnimation then
  begin
    Result := TFloatAnimation(AnAnimation).PropertyName;
    Exit;
  end;

  if AnAnimation is TFloatKeyAnimation then
  begin
    Result := TFloatKeyAnimation(AnAnimation).PropertyName;
    Exit;
  end;

  if AnAnimation is TGradientAnimation then
  begin
    Result := TGradientAnimation(AnAnimation).PropertyName;
    Exit;
  end;

  if AnAnimation is TColorAnimation then
  begin
    Result := TColorAnimation(AnAnimation).PropertyName;
    Exit;
  end;

  if AnAnimation is TColorKeyAnimation then
  begin
    Result := TColorKeyAnimation(AnAnimation).PropertyName;
    Exit;
  end;

  if AnAnimation is TRectAnimation then
  begin
    Result := TRectAnimation(AnAnimation).PropertyName;
    Exit;
  end;

  if AnAnimation is TBitmapAnimation then
  begin
    Result := TBitmapAnimation(AnAnimation).PropertyName;
    Exit;
  end;

  if AnAnimation is TBitmapListAnimation then
  begin
    Result := TBitmapListAnimation(AnAnimation).PropertyName;
    Exit;
  end;

end;


function ComponentOfPersistent(APersistent: TPersistent): TComponent;
begin
  while Assigned(APersistent) do
  begin
     if APersistent is TOwnedCollection then
      APersistent := TOwnedCollection(APersistent).Owner
    else if APersistent is TCollectionItem then
      APersistent := TCollectionItem(APersistent).Collection
    else if APersistent is TComponent then
      Break
    else
      APersistent := nil;
  end;
  Result := TComponent(APersistent);
end;

function FMXObjectOfDesigner(const ADesigner: IDesigner;
                             const AIndex: Integer = 0): TFmxObject;
var
  LSelections: IDesignerSelections;
  LComp: TComponent;
begin
  Result := nil;
  if Assigned(ADesigner) and (AIndex >= 0) then
  begin
    LSelections := TDesignerSelections.Create;
    ADesigner.GetSelections(LSelections);
    if Assigned(LSelections) and (AIndex < LSelections.Count) then
    begin
      LComp := ComponentOfPersistent(LSelections.Items[AIndex]);
      if LComp is TFmxObject then
        Result := TFmxObject(LComp);
    end;
  end;
end;

function IsAnimatedImpl(const APropertyPath: string; const ADesigner: IDesigner): Boolean;
var
  BO, LChild: TFmxObject;
  I: Integer;
begin
  Result := False;
  BO := FMXObjectOfDesigner(ADesigner);
  if Assigned(BO) then
  for I := 0 to BO.ChildrenCount - 1 do
  begin
    LChild := BO.Children[I];
    if (LChild is TAnimation) and
       (APropertyPath = GetPropertyName(TAnimation(LChild))) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TMaterialColorProperty.TextToMaterialColor(const Value: string): TAlphaColor;
begin
  Result := StringToMaterialColor(Value);
end;

function PaintColorBox(const Value: TAlphaColor; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean): TRect;
  overload;
const
  SquareSize = 3;
var
  Right, Size: Integer;
  NewRect: TRect;
  OldPenColor, OldBrushColor: TColor;
begin
  Right := (ARect.Bottom - ARect.Top) { * 2 } + ARect.Left;
  // save off things
  OldBrushColor := ACanvas.Brush.Color;
  OldPenColor := ACanvas.Pen.Color;
  try
    Size := ((ARect.Height - 4) div SquareSize) * SquareSize + 2;
    NewRect := TRect.Create(ARect.TopLeft, Size, Size);
    NewRect.Offset(FilmStripMargin, (ARect.Height - NewRect.Height + 1) div 2);
    if FMXBitmap = nil then
      FMXBitmap := FMX.Graphics.TBitmap.Create(Size - 2, Size - 2)
    else
      FMXBitmap.SetSize(Size - 2, Size - 2);
    FMXBitmap.Clear(Value);
    CreatePreview(FMXBitmap, VCLBitmap, TRect.Create(TPoint.Create(0, 0), FMXBitmap.Width, FMXBitmap.Height), clBlack,
      clWhite, SquareSize, True);
    ACanvas.Pen.Color := ACanvas.Brush.Color;
    ACanvas.Rectangle(ARect.Left, ARect.Top, Right, ARect.Bottom);
    if ASelected then
      ACanvas.Pen.Color := clHighlightText
    else
      ACanvas.Pen.Color := clWindowText;
    ACanvas.Rectangle(NewRect);
    ACanvas.Draw(NewRect.Left + 1, NewRect.Top + 1, VCLBitmap);
  finally
    // restore the things we twiddled with
    ACanvas.Pen.Color := OldPenColor;
    ACanvas.Brush.Color := OldBrushColor;
    Result := Rect(Right, ARect.Top, ARect.Right, ARect.Bottom);
  end;
end;

function PaintColorBox(const Value: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean): TRect; overload;
var
  LValue: TMaterialColor;
begin
  LValue := StringToMaterialColor(Value);
  Result := PaintColorBox(LValue, ACanvas, ARect, ASelected);
end;

function PaintFilmStrip(const Value: string; ACanvas: TCanvas; const ARect: TRect;
  IsAnimated: Boolean): TRect;
var
  I, Right, Left, Top: Integer;
  OldPenColor, OldBrushColor: TColor;
  BorderColor, CellColor: TColor;
begin
  Left := ARect.Left + FilmStripMargin;
  Right := Left + FilmStripWidth;
  Top := ARect.Top + Round((ARect.Bottom - ARect.Top - FilmStripHeight) / 2);
  with ACanvas do
  begin
    // save off things
    OldPenColor := Pen.Color;
    OldBrushColor := Brush.Color;

    Pen.Color := ACanvas.Brush.Color;
    Rectangle(ARect.Left, ARect.Top, Right + FilmStripMargin, ARect.Bottom);
    // frame things
    if IsAnimated then
    begin
      BorderColor := TColors.Black;
      CellColor := TColors.LtGray;
    end
    else
    begin
      BorderColor := TColors.LtGray;
      CellColor := TColors.White;
    end;

    Pen.Color := BorderColor;
    Rectangle(Left, Top, Right, Top + FilmStripHeight);
    for I := 0 to 2 do
    begin
      Rectangle(Left, Top + 2 + (4 * I), Right, Top + 5 + (4 * I));
    end;
    Rectangle(Left + 2, Top, Right - 2, Top + FilmStripHeight);

    Brush.Color := CellColor;
    Pen.Color := CellColor;
    Rectangle(Left + 3, Top, Right - 3, Top + FilmStripHeight);

    Pen.Color := BorderColor;
    Rectangle(Left + 2, Top + 3, Right - 2, Top + FilmStripHeight - 3);

    // restore the things we twiddled with
    Brush.Color := OldBrushColor;
    Pen.Color := OldPenColor;
    Result := Rect(Right + FilmStripMargin, ARect.Top, ARect.Right, ARect.Bottom);
  end;
end;

{ TMaterialColorProperty }

procedure TMaterialColorProperty.CreateNewAnimation(AnimationClass: TComponentClass);
var
  BO: TFmxObject;
  LAni: TAnimation;
  LPropName: string;
begin
  LPropName := (BorlandIDEServices as IOTAPropInspServices).Selection.GetActiveItem;
  BO := FMXObjectOfDesigner(Designer);
  if Assigned(BO) then
  begin
    LAni := TAnimation(Designer.CreateComponent(AnimationClass, BO, 0,0,0,0));
    LAni.Parent := BO;
    if LAni is TColorAnimation then
      TColorAnimation(LAni).PropertyName := LPropName;
    if LAni is TColorKeyAnimation then
      TColorKeyAnimation(LAni).PropertyName := LPropName;
  end;
end;

procedure TMaterialColorProperty.Edit;
begin
  inherited;

end;

function TMaterialColorProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paDialog, paValueList, paRevertable];
end;

function TMaterialColorProperty.GetValue: string;
begin
  try
    Result := MaterialColorToString(TMaterialColor(GetOrdValue));
  except
    // on E: Exception do ShowMessage(E.Message);
  end;
end;

procedure TMaterialColorProperty.GetValues(Proc: TGetStrProc);
begin
  GetMaterialColorValues(Proc);
end;

function TMaterialColorProperty.IsAnimated: Boolean;
begin
  Result := IsAnimatedImpl(FPropertyPath, Designer);
end;

procedure TMaterialColorProperty.ListDrawValue(const Value: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  ValueRect: TRect;
begin
  if (not SameText(Value, SCreateNewColorAnimation)) and
    (not SameText(Value, SCreateNewColorKeyAnimation)) then
    ValueRect := PaintColorBox(Value, ACanvas, ARect, ASelected)
  else
    ValueRect := PaintFilmStrip(Value, ACanvas, ARect, True);
  DefaultPropertyListDrawValue(Value, ACanvas, ValueRect, ASelected);
end;

procedure TMaterialColorProperty.ListMeasureHeight(const Value: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  AHeight := ((FilmStripHeight + 2 * FilmStripMargin) div 2 + 1) * 2;
end;

procedure TMaterialColorProperty.ListMeasureWidth(const Value: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + ACanvas.TextHeight('M') { * 2 };
end;

procedure TMaterialColorProperty.PropDrawName(ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
begin
  DefaultPropertyDrawName(Self, ACanvas, ARect);
end;

function TMaterialColorProperty.PropDrawNameRect(const ARect: TRect): TRect;
begin
  Result := ARect;
end;

procedure TMaterialColorProperty.PropDrawValue(ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  LRect: TRect;
begin
  if GetVisualValue <> '' then
  begin
    LRect := PaintFilmStrip(GetVisualValue, ACanvas, ARect, IsAnimated);
    PaintColorBox(TextToMaterialColor(GetVisualValue), ACanvas, LRect, False);
  end
  else
    DefaultPropertyDrawValue(Self, ACanvas, ARect);
end;

function TMaterialColorProperty.PropDrawValueRect(const ARect: TRect): TRect;
begin
  Result := Rect(ARect.Left, ARect.Top, FilmStripMargin * 2 + FilmStripWidth +
    (ARect.Bottom - ARect.Top) + ARect.Left, ARect.Bottom);
end;

procedure TMaterialColorProperty.SetPropertyPath(const Value: string);
begin
  FPropertyPath := Value;
end;

procedure TMaterialColorProperty.SetValue(const Value: string);
begin
  try
    SetOrdValue(Integer(StringToMaterialColor(Value)));
    Modified;
  except
    // on E: Exception do ShowMessage(E.Message);
  end;

end;

end.
