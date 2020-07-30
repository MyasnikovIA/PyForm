program PyFormProject;

uses
  ParseDFMUnit,
  System.RTTI,
  System.TypInfo,
  System.Types,
  System.SysUtils,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Memo,
  System.StartUpCopy,
  PyFormUnit in 'PyFormUnit.pas' {MainForm};

{$R *.res}

var
   MainForm: TMainForm;
   formText: TStringList;
   NumLine:integer;
   Parse : TParse;
begin
  formText := TStringList.Create;
formText.Add('object Form1: TForm1');
  formText.Add('  Left = 0');
  formText.Add('  Top = 0');
  formText.Add('  Caption = ''Form1''');
  formText.Add('  ClientHeight = 307');
  formText.Add('  ClientWidth = 573');
  formText.Add('  FormFactor.Width = 320');
  formText.Add('  FormFactor.Height = 480');
  formText.Add('  FormFactor.Devices = [Desktop]');
  formText.Add('  DesignerMasterStyle = 0');
  formText.Add('  object Button1: TButton');
  formText.Add('    Position.X = 16.000000000000000000');
  formText.Add('    Position.Y = 40.000000000000000000');
  formText.Add('    Size.Width = 113.000000000000000000');
  formText.Add('    Size.Height = 25.000000000000000000');
  formText.Add('    Size.PlatformDefault = False');
  formText.Add('    TabOrder = 0');
  formText.Add('    Text = ''Button1''');
  formText.Add('    OnClick = Button1Click');
  formText.Add('  end');
  formText.Add('  object Edit1: TEdit');
  formText.Add('    Touch.InteractiveGestures = [LongTap, DoubleTap]');
  formText.Add('    TabOrder = 1');
  formText.Add('    Position.X = 16.000000000000000000');
  formText.Add('    Position.Y = 8.000000000000000000');
  formText.Add('    Size.Width = 113.000000000000000000');
  formText.Add('    Size.Height = 22.000000000000000000');
  formText.Add('    Size.PlatformDefault = False');
  formText.Add('  end');
  formText.Add('  object Button2: TButton');
  formText.Add('    Position.X = 16.000000000000000000');
  formText.Add('    Position.Y = 96.000000000000000000');
  formText.Add('    Size.Width = 113.000000000000000000');
  formText.Add('    Size.Height = 22.000000000000000000');
  formText.Add('    Size.PlatformDefault = False');
  formText.Add('    TabOrder = 2');
  formText.Add('    Text = ''Button2''');
  formText.Add('    OnClick = Button2Click');
  formText.Add('  end');
  formText.Add('  object Button3: TButton');
  formText.Add('    Position.X = 152.000000000000000000');
  formText.Add('    Position.Y = 96.000000000000000000');
  formText.Add('    TabOrder = 3');
  formText.Add('    Text = ''Button3''');
  formText.Add('    OnClick = Button3Click');
  formText.Add('  end');
  formText.Add('  object Button4: TButton');
  formText.Add('    Position.X = 152.000000000000000000');
  formText.Add('    Position.Y = 40.000000000000000000');
  formText.Add('    TabOrder = 5');
  formText.Add('    Text = ''Button4''');
  formText.Add('  end');
  formText.Add('end');
  {
  formText.Add('object TMyForm: TTMyForm');
  formText.Add('  Left = 0');
  formText.Add('  Top = 0');
  formText.Add('  Caption = ''Form2''');
  formText.Add('  ClientHeight = 308');
  formText.Add('  ClientWidth = 566');
  formText.Add('  Fill.Kind = Solid');
  formText.Add('  FormFactor.Width = 320');
  formText.Add('  FormFactor.Height = 480');
  formText.Add('  FormFactor.Devices = [Desktop]');
  formText.Add('  DesignerMasterStyle = 3');
  formText.Add('  object Edit1: TEdit');
  formText.Add('    Touch.InteractiveGestures = [LongTap, DoubleTap]');
  formText.Add('    Anchors = [akLeft, akTop, akRight]');
  formText.Add('    TabOrder = 0');
  formText.Add('    Position.X = 8.000000000000000000');
  formText.Add('    Position.Y = 8.000000000000000000');
  formText.Add('    Size.Width = 553.000000000000000000');
  formText.Add('    Size.Height = 32.000000000000000000');
  formText.Add('    Size.PlatformDefault = False');
  formText.Add('    OnClick = Edit1Click');
  formText.Add('  end');
  formText.Add('end');
  }

  Application.Initialize;
  MainForm:= TMainForm.Create(Application);
  try
      MainForm.Parent := nil;
      NumLine:= 0;
      Parse := TParse.Create;
      Parse.DFM(formText,NumLine,0,MainForm,MainForm);
      MainForm.ShowModal;
  except
    MainForm.Free ;
  end;
  // Application.Run;
end.
