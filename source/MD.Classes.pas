unit MD.Classes;

interface

uses
  FMX.Graphics, MD.ColorPalette, System.Classes, FMX.Types;

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

implementation

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
