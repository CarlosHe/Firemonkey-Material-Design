unit MD.Cards;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, MD.ColorPalette, FMX.Controls, FMX.Graphics, System.Types;

type
  TMDCard = class(TControl)
  private
    { Private declarations }
    FMaterialColor: TMaterialColor;
    FFill: TBrush;
    function GetFill: TBrush;
    procedure SetFill(const Value: TBrush);
    function GetMaterialColor: TMaterialColor; virtual;
    procedure SetMaterialColor(const Value: TMaterialColor); virtual;
  protected
    { Protected declarations }
    property Fill: TBrush read GetFill write SetFill;
    property HitTest default True;
    property CanFocus default False;
    procedure Paint; override;
    procedure FillChanged(Sender: TObject); virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property ClipParent;
    property Cursor;
    property DragMode;
    property EnableDragHighlight;
    property Enabled;
    property Locked;
    property Height;
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
    property MaterialColor: TMaterialColor read GetMaterialColor write SetMaterialColor;
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
  end;

implementation

{ TMDCard }

constructor TMDCard.Create(AOwner: TComponent);
begin
  inherited;
  Self.ClipChildren := True;
  Self.Height := 400;
  Self.Width := 350;
  Self.CanFocus := False;
  Self.TabStop := False;
  Self.HitTest := False;

  FMaterialColor := TMaterialColors.White;
  FFill := TBrush.Create(TBrushKind.Solid, FMaterialColor);
  FFill.OnChanged := FillChanged;

end;

destructor TMDCard.Destroy;
begin
  FreeAndNil(FFill);
  inherited;
end;

procedure TMDCard.FillChanged(Sender: TObject);
begin
  Repaint;
end;

function TMDCard.GetFill: TBrush;
begin
  Result := FFill;
end;

function TMDCard.GetMaterialColor: TMaterialColor;
begin
  Result := FMaterialColor;
end;

procedure TMDCard.Paint;
begin
  inherited;
   Canvas.BeginScene;
  Canvas.FillRect(TRectF.Create(0, 0, Self.Width, Self.Height), 5, 5, [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight],
    AbsoluteOpacity, FFill, TCornerType.Round);
   Canvas.EndScene;

end;

procedure TMDCard.SetFill(const Value: TBrush);
begin
  FFill.Assign(Value);
end;

procedure TMDCard.SetMaterialColor(const Value: TMaterialColor);
begin
  FMaterialColor := Value;
  if Assigned(FFill) then
    FFill.Color := FMaterialColor;
end;

end.
