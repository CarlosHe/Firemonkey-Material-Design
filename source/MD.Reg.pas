unit MD.Reg;

interface

uses
  System.Classes, MD.Buttons, MD.ColorListBox, FMX.Types, DesignEditors, DesignIntf, ToolsAPI, FMXEditors, MD.ColorPalette, MD.Editors,
  System.UITypes,
  MD.Input;

procedure Register;

implementation

uses MD.Cards, MD.TextFields, MD.Layouts;

procedure Register;
begin
  RegisterComponents('Material Design', [TMDFlatButton]);
  RegisterComponents('Material Design', [TMDRaisedButton]);
  RegisterComponents('Material Design', [TMaterialColorListBox]);
  RegisterComponents('Material Design', [TMDFlowLayout]);
  RegisterComponents('Material Design', [TMDCard]);
  RegisterComponents('Material Design', [TMDEdit]);
  // RegisterComponents('Material Design', [TMDTextFields]);
  RegisterPropertyEditor(TypeInfo(MD.ColorPalette.TMaterialColor), System.Classes.TPersistent, '', TMaterialColorProperty);
  RegisterPropertyEditor(TypeInfo(TAlphaColor), System.Classes.TPersistent, '', TMaterialColorProperty);
  RegisterPropertyEditor(TypeInfo(TAlphaColor), FMX.Types.TFmxObject, '', TMaterialColorProperty);
end;

end.
