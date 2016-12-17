unit MD.Reg;

interface

uses
  System.Classes, MD.ColorListBox, FMX.Types, DesignEditors, DesignIntf, ToolsAPI, FMXEditors, MD.ColorPalette, MD.Editors, System.UITypes;

procedure Register;

implementation

uses MD.Cards, MD.TextFields, MD.Layouts;

procedure Register;
begin

  RegisterComponents('Material Design', [TMaterialColorListBox]);
  RegisterComponents('Material Design', [TMDCard]);
  RegisterPropertyEditor(TypeInfo(MD.ColorPalette.TMaterialColor), System.Classes.TPersistent, '', TMaterialColorProperty);
end;

end.
