{ *************************************************************************** }
{                                                                             }
{ Delphi and Kylix Cross-Platform Component                                   }
{ Cache connect components                                                    }
{                                                                             }
{ component TCacheConnect version 1.0 for Delphi 6.0 and Kylix 1.0            }
{ *************************************************************************** }
//{$I CCcross.inc}
// {$DEFINE TUNE}
unit TPyConnectUnit;

interface
  uses
  IdGlobal,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type

   TMReadEvent = procedure( Sender : TObject; Value: string) of object;

    // ����� ��� �������� ������ � �������
  TPyConnectThread = class(TThread)
  private
    FConn: TIdTCPConnection;
    FOnRead: TMReadEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AConn: TIdTCPConnection;FunOnRead: TMReadEvent); reintroduce;
  end;

  TPyConnect = class(TComponent)
  private
    FHost: String;
    FPort:Integer;
    FActive: Boolean;
    FIdTCPClient1: TIdTCPClient;
    FPyConnectThread : TPyConnectThread ;
    FOnRead: TMReadEvent;

    // ���������� �������
    FDeleteProperty:  String;
    FDeleteEvent: TNotifyEvent;

  public
      constructor Create( AOwner: TComponent); override;
      destructor Destroy; override;
      procedure Connect();
      procedure Disconnect();
      procedure Send(msg: String);
 protected
    { Protected declarations }
    procedure SetHost(Value: String);
    procedure SetPort(Value: Integer);
    procedure SetActive( AActive: Boolean);

  public
    { Public declarations }
  published
     property Host: String read FHost write SetHost;
     property Port: Integer read FPort write SetPort;
     property Active: Boolean read FActive write SetActive stored false;
     property OnRead : TMReadEvent read FOnRead write FOnRead;
  end;

procedure Register;

implementation



{  TMConnect }
constructor  TPyConnect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //-----------
//  FIdTCPClient1:= TIdTCPClient.Create(AOwner);
    FIdTCPClient1:= TIdTCPClient.Create(nil);
end;

destructor  TPyConnect.Destroy;
begin
   Disconnect();
   FreeAndNil(FIdTCPClient1);
   // FIdTCPClient1.Free;
   // FIdTCPClient1 :=nil;
   //----------
  inherited Destroy;
end;

procedure TPyConnect.Connect();
begin
  FIdTCPClient1.Port:=FPort;
  FIdTCPClient1.Host:=FHost;
  FIdTCPClient1.Connect;
  try
    FPyConnectThread := TPyConnectThread.Create(FIdTCPClient1,FOnRead);
  except
    FIdTCPClient1.Disconnect;
    raise;
  end;
end;

procedure TPyConnect.Disconnect();
begin
 if Assigned(FPyConnectThread) then FPyConnectThread.Terminate;
  try
    FIdTCPClient1.Disconnect;
  finally
    if Assigned(FPyConnectThread) then
    begin
      FPyConnectThread.WaitFor;
      FreeAndNil(FPyConnectThread);
    end;
  end;
end;


procedure TPyConnect.Send(msg: String);
begin
   FIdTCPClient1.IOHandler.DefStringEncoding:= IndyTextEncoding_OSDefault;
   FIdTCPClient1.Socket.WriteLn(msg);
end;

procedure TPyConnect.SetHost(Value: String);
begin
   Disconnect();
   FHost:=Value;
end;

procedure TPyConnect.SetPort(Value: Integer);
begin
   Disconnect();
   FPort:=Value;
end;


procedure TPyConnect.SetActive(AActive: Boolean);
begin
    Disconnect();
    Connect();
    FActive:=AActive
end;

{  TPyConnectThread }


constructor TPyConnectThread.Create(AConn: TIdTCPConnection;FunOnRead: TMReadEvent);
begin
  inherited Create(False);
  FConn := AConn;
  FOnRead := FunOnRead;
end;

procedure TPyConnectThread.Execute;
var
  Str: String;
  s:TStringStream;
  strem:TStream;
  stL: TStringList;
begin
  while not Terminated do
  begin

   //  strem:=TStream.Create;
   //  stL:= TStringList.Create;
   //  FConn.IOHandler.ReadStream(strem); //������ �� ��������� � �����
   //  strem.Position:=0;
   //  stL.LoadFromStream(strem);
   //  Form1.Memo1.Lines.Add(stL.Text);
   //  FreeAndNil(strem);
   //  FreeAndNil(stL);
      //      s:=TStringStream.Create;  //������������� ������ s
      //      FConn.IOHandler.ReadStream(s); //������ �� ��������� � �����
      //      s.Position:=0;  //��������� ������� �� ������ ������ s
      //      Form1.Memo1.Lines.Add(s.ReadString(s.Size)); //������ ��������� ��������� � Memo
      //      s.Free;  //����������� ������ s

   //  Str :=  FConn.IOHandler.AllData(IndyTextEncoding_OSDefault);
   //  Form1.Memo1.Lines.Add(Str)

      Str := FConn.IOHandler.ReadLn(IndyTextEncoding_OSDefault);
      if Assigned(FOnRead) then
      begin
        FOnRead( Self, Str);
      end;

     // Form1.Memo1.Lines.Add(Str);
  end;
end;


{ registration}
procedure Register;
begin
   RegisterComponents('PyConnect', [TPyConnect]);
end;

end.
