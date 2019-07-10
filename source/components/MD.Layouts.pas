unit MD.Layouts;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts;

type
  TMDFlowLayout = class(TFlowLayout)
  private
    { Private declarations }
    FAutoAjustHeight: Boolean;
    FMinHeight: Single;
    procedure SetMinHeight(const Value: Single);
  protected
    { Protected declarations }
    procedure Painting; override;
    procedure Paint; override;
    procedure DoAjustHeight;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoRemoveObject(const AObject: TFmxObject); override;
  public
    { Public declarations }
    procedure DoRealign; override;
  published
    { Published declarations }
    property AutoAjustHeight: Boolean read FAutoAjustHeight write FAutoAjustHeight default False;
    property MinHeight: Single read FMinHeight write SetMinHeight;
  end;

implementation

{ TMDFlowLayout }

procedure TMDFlowLayout.DoAddObject(const AObject: TFmxObject);
begin
  inherited;
end;

procedure TMDFlowLayout.DoAjustHeight;
var
  i: integer;
  ObjHeight: Single;
begin
  if (FAutoAjustHeight) then
  begin
    ObjHeight := FMinHeight;
    if (Self.ChildrenCount - 1 >= 0) and ((csDesigning in ComponentState) or (ComponentState = [])) then
    begin
      for i := 0 to Self.ChildrenCount - 1 do
      begin
        if Self.Children[i].InheritsFrom(TControl) then
          if TControl(Self.Children[i]).Height + TControl(Self.Children[i]).Position.Y > ObjHeight then
          begin
            ObjHeight := TControl(Self.Children[i]).Height + TControl(Self.Children[i]).Position.Y + Self.Padding.Bottom;
          end;
      end;
      if ObjHeight > FMinHeight then
        Self.Height := ObjHeight
      else
        Self.Height := FMinHeight;
    end;
    if Self.Height < FMinHeight then
      Self.Height := FMinHeight;
  end;
  UpdateEffects;
end;

procedure TMDFlowLayout.DoRealign;
begin
  inherited;

end;

procedure TMDFlowLayout.DoRemoveObject(const AObject: TFmxObject);
begin
  inherited;
  DoAjustHeight;
end;

procedure TMDFlowLayout.Paint;
begin
  inherited;
  if (csDesigning in ComponentState) and not Locked then
    DrawDesignBorder;
end;

procedure TMDFlowLayout.Painting;
begin
  DoAjustHeight;
  inherited;
end;

procedure TMDFlowLayout.SetMinHeight(const Value: Single);
begin
  FMinHeight := Value;
end;

end.
