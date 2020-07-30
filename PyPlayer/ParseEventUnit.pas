unit ParseEventUnit;

interface

uses

  System.RTTI,
  System.TypInfo,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit;

type
  TComponentEvent = class(TObject)
  public
    // function Log_write(fname, text:string):string;
    procedure SetEvent(var Sender: TObject; PropertyObject : TRttiProperty; NameEvent:String; ValueEvent:String);
  end;

  TNotifyEventRef = reference to procedure(Sender: TObject);


  TNotifyEventWrapper = class(TComponent)
  private
    FProc: TProc<TObject>;
    Fstr: String;
  public
     constructor Create(Owner: TComponent; Proc: TProc<TObject>;const str:String );
  published
    procedure Event(Sender: TObject);
  end;

implementation


constructor TNotifyEventWrapper.Create(Owner: TComponent; Proc: TProc<TObject>;const str:String );
begin
  inherited Create(Owner);
  FProc := Proc;
  Fstr := str;
end;

/// необходимо дописать разные варианты процедур при вызове разных событий
procedure TNotifyEventWrapper.Event(Sender: TObject);
begin
  // Прописать передачу команды на сервер
  ShowMessage((Sender as TComponent).Name + ' '+  Fstr);
  // FProc(Sender); //  Вызов процедуры
end;

function AnonProc2NotifyEvent(Owner: TComponent;const str:String ;Proc: TProc<TObject>): TNotifyEvent;
begin
  Result := TNotifyEventWrapper.Create(Owner, Proc,str).Event;
end;



procedure TComponentEvent.SetEvent(var Sender: TObject; PropertyObject : TRttiProperty; NameEvent:String; ValueEvent:String);
begin
  if ( PropertyObject.PropertyType.QualifiedName = 'System.Classes.TNotifyEvent' ) then
  begin
       PropertyObject.SetValue(Sender,
              TValue.From<TNotifyEvent>(
                 AnonProc2NotifyEvent( (Sender as TComponent), NameEvent ,  procedure(Sender: TObject) begin   end)
              )
       );
  end;
end;




end.
