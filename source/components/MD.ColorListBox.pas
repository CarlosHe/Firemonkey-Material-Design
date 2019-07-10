unit MD.ColorListBox;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts, FMX.ListBox, System.Rtti, System.UITypes, FMX.Objects, System.UIConsts,
  MD.ColorPalette;

type
  TMaterialColorListBox = class(TCustomListBox)
  private
    procedure SetMaterialColor(const Value: TMaterialColor);
    function GetMaterialColor: TMaterialColor;
    procedure DoItemApplyStyleLookup(Sender: TObject);
  protected
    function GetData: TValue; override;
    procedure SetData(const Value: TValue); override;
    procedure RebuildList;
    function GetDefaultStyleLookupName: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property MaterialColor: TMaterialColor read GetMaterialColor write SetMaterialColor default TMaterialColorRec.Null;
    property Align;
    property AllowDrag;
    property AlternatingRowBackground;
    property Anchors;
    property CanFocus;
    property CanParentFocus;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DisableFocusEffect default True;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Locked default False;
    property Height;
    property HitTest default True;
    property ItemIndex;
    property ItemHeight;
    property ItemWidth;
    property DefaultItemStyles;
    property GroupingKind;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property StyleLookup;
    property TabOrder;
    property TabStop;
    property Visible default True;
    property Width;

    { events }
    property OnApplyStyleLookup;
    property OnChange;
    { Drag and Drop events }
    property OnDragChange;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    { Keyboard events }
    property OnKeyDown;
    property OnKeyUp;
    { Mouse events }
    property OnCanFocus;
    property OnItemClick;

    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;

    property OnPainting;
    property OnPaint;
    property OnResize;
  end;

implementation


{ TMaterialColorListBox }

constructor TMaterialColorListBox.Create(AOwner: TComponent);
begin
  inherited;
  RebuildList;
  SetAcceptsControls(False);
end;

destructor TMaterialColorListBox.Destroy;
begin

  inherited;
end;

procedure TMaterialColorListBox.DoItemApplyStyleLookup(Sender: TObject);
var
  ColorObj: TShape;
begin
  if TListBoxItem(Sender).FindStyleResource<TShape>('color', ColorObj) then
    ColorObj.Fill.Color := MaterialColorsMap.MaterialColor[TListBoxItem(Sender).Tag].Value;
end;

function TMaterialColorListBox.GetData: TValue;
begin
  Result := TValue.From<TMaterialColor>(MaterialColor);
end;

function TMaterialColorListBox.GetDefaultStyleLookupName: string;
begin
  Result := 'listboxstyle';
end;

function TMaterialColorListBox.GetMaterialColor: TMaterialColor;
begin
  if (ItemIndex >= 0) and (ItemIndex < Count) then
    Result := MaterialColorsMap.MaterialColor[ItemIndex].Value
  else
    Result := TMaterialColorRec.Null;
end;

procedure TMaterialColorListBox.RebuildList;
var
  I, SaveIndex: Integer;
  Item: TListBoxItem;
begin
  if (FUpdating > 0) or (csDestroying in ComponentState) then
    Exit;

  BeginUpdate;
  SaveIndex := ItemIndex;
  Clear;
  for I := 0 to MaterialColorsMap.Count - 1 do
  begin
    Item := TListBoxItem.Create(nil);
    Item.Parent := Self;
    Item.Width := Item.DefaultSize.Width;
    Item.Height := Item.DefaultSize.Height;
    Item.Stored := False;
    Item.Locked := True;
    Item.Text := MaterialColorsMap.MaterialColor[I].Name;
    Item.Tag := I;
    Item.StyleLookup := 'colorlistboxitemstyle';
    Item.OnApplyStyleLookup := DoItemApplyStyleLookup;
  end;
  SelectionController.SetCurrent(SaveIndex);
  EndUpdate;
end;

procedure TMaterialColorListBox.SetData(const Value: TValue);
begin
  inherited;
  if Value.IsType<TNotifyEvent> then
    OnChange := Value.AsType<TNotifyEvent>()
  else if Value.IsType<TMaterialColor> then
    MaterialColor := Value.AsType<TMaterialColor>
  else
    MaterialColor := StringToAlphaColor(Value.ToString);
end;

procedure TMaterialColorListBox.SetMaterialColor(const Value: TMaterialColor);
var
  I: Integer;
begin
  if Value = TMaterialColorRec.Null then
    ItemIndex := -1
  else
    for I := 0 to MaterialColorsMap.Count - 1 do
      if MaterialColorsMap.MaterialColor[I].Value = Value then
      begin
        ItemIndex := I;
        Break;
      end;
end;

procedure InitColorsMap;
begin
  MaterialColorsMap := TRTLMaterialColors.Create;
end;

procedure DestroyColorsMap;
begin
  FreeAndNil(MaterialColorsMap);
end;

initialization

InitColorsMap;
RegisterFmxClasses([TMaterialColorListBox]);

finalization

DestroyColorsMap;

end.
