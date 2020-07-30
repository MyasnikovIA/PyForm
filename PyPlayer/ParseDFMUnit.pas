unit ParseDFMUnit;

interface

uses

  ParseEventUnit,
  PyFormUnit,
  System.RTTI,
  System.TypInfo,
  System.Types,
  System.StrUtils,
  System.UIConsts,
  System.UITypes,
  Generics.Collections ,
//  FMX.TWinControl,
  System.SysUtils, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, TPyConnectUnit, FMX.Edit,
  FMX.ScrollBox, FMX.Memo;
type

  // јнонимные функции
  // http://smartpascal.github.io/help/assets/hm_anonymous_methods.htm
 TProcedureRef = procedure;

  TAnchorKind = (akLeft, akTop, akRight, akBottom);
  TAnchors = set of TAnchorKind;

  TEventComponent = class(TObject)
  public
     ClassName:String;
     ComponentClassInfo :Pointer;
     EventName:String;
     EventType:String;
     NameComponent:String;
     ParentComponent:String;
     EventTypeInfo:String;
     ParentObject:TObject;
     EventObject:TObject;
  end;

  TParse = class(TComponentEvent)
  public
    EventList: TDictionary<string,TEventComponent>;
    procedure DFM(var DFMtext: TStringList; var NumLine:Integer; CountBSobject:Integer; obj:TObject; objParent:TObject);
    // https://itqna.net/questions/79609/delphi-rtti-get-property-value-object-owned-another
    procedure SetObjEvent(const Prop:string;AInstance:TObject;Value:String);
    // ---- https://stackoverrun.com/ru/q/1958550 -------
    procedure SetObjValueEx(const ObjPath:string;AInstance:TObject;Value:String);
    function  GetObjValueEx(const ObjPath:string;AInstance:TObject):TValue;
    // --------------------------------------------------
    function GetFullNameClass(className:String):String;
    function getConvertValue(Prop: TRttiProperty;PropVal:String):TValue;
    //https://stackoverflow.com/questions/26354869/tcontrol-child-to-tobject-and-set-its-parent-property-via-rtti-or-setxxxxxxpro
    procedure SetControlParent(obj, parent: TObject);
    function GetControlParent(obj: TObject):TObject;
    function StrToSingle(Str: string): Single;
    function StrToAnchors(Str: string): TAnchors;

    procedure MyNotifyEvent(Sender: TObject);
    procedure FMX_KeyEvent(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState) ;

  end;



implementation



procedure TParse.MyNotifyEvent(Sender: TObject);
begin
   ShowMessage('MyNotifyEvent '+Sender.ToString );
end;

procedure TParse.FMX_KeyEvent(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState) ;
begin
   ShowMessage('FMX.Types.TKeyEvent '+Sender.ToString );
end;


function  StringToTBrushKind(val:String):TBrushKind;
begin
   //  TBrushKind = (None, Solid, Gradient, Bitmap, Resource);
  if val = 'Solid' then  Result := TBrushKind.Solid
  else if  val = 'Gradient' then Result := TBrushKind.Gradient
  else if  val = 'Bitmap' then Result := TBrushKind.Bitmap
  else if  val = 'Resource' then Result := TBrushKind.Resource
  else Result := TBrushKind.None;
end;

function  StringToTDeviceKind(val:String):TDeviceKind;
begin
   //   TDeviceKind = (Desktop, iPhone, iPad);
   if val = 'Desktop' then Result := TDeviceKind.Desktop
   else if  val =  'iPhone' then Result := TDeviceKind.iPhone
   else if  val =  'iPad' then Result := TDeviceKind.iPad
   else Result := TDeviceKind.Desktop;
end;


function TParse.StrToSingle(Str: string): Single;
var
    r:Single;
    pos:integer;
begin
    Val(Str,r,pos);
    if pos > 0 then Val(Copy(Str,21,pos-1),r,pos);
    Result:=r;
end;


function TParse.StrToAnchors(Str: string): TAnchors;

begin
    Result:=[akLeft, akTop];
    //ƒќѕ»—ј“№ комбинации
    if Str='[akLeft]'   then begin  Result:=[akLeft];     exit;  end;
    if Str='[akTop]'    then begin  Result:=[akTop];      exit;  end;
    if Str='[akRight]'  then begin  Result:=[akRight];    exit;  end;
    if Str='[akBottom]' then begin  Result:=[akBottom];   exit;  end;
    if Str='[]'         then begin  Result:=[];           exit;  end;

    if Str='[akLeft,akTop]' then begin   Result:=[akLeft,akTop];     exit;  end;
    if Str='[akLeft,akRight]' then begin  Result:=[akLeft,akRight];    exit;  end;
    if Str='[akLeft,akBottom]' then begin Result:=[akLeft,akBottom];   exit;  end;

    if Str='[akLeft,akTop]' then begin   Result:=[akLeft,akTop];     exit;  end;
    if Str='[akLeft,akRight]' then begin  Result:=[akLeft,akRight];    exit;  end;
    if Str='[akLeft,akBottom]' then begin Result:=[akLeft,akBottom];   exit;  end;

    if Str='[akLeft, akRight]' then begin Result:=[akLeft,akRight];   exit;  end;
    if Str='[akLeft, akRight,akBottom]' then begin Result:=[akLeft,akRight,akBottom];   exit;  end;
    if Str='[akLeft, akTop, akRight]' then begin Result:=[akLeft, akTop, akRight];   exit;  end;
    if Str='[akLeft, akTop, akRight, akBottom]' then begin Result:=[akLeft, akTop, akRight, akBottom];   exit;  end;
end;



function TParse.getConvertValue(Prop: TRttiProperty;PropVal:String):TValue;
begin
    Result := TValue.Empty;
    if Prop.PropertyType.ToString='Integer'      then   Result := TValue.From(StrToInt(PropVal));
    if Prop.PropertyType.ToString='string'       then   Result := TValue.From( copy(PropVal,2,Length(PropVal)-2));
    if Prop.PropertyType.ToString='Boolean'      then   Result := TValue.From(StrToBool(PropVal) );
    if Prop.PropertyType.ToString='TAlphaColor'  then   Result := TValue.From(StringToAlphaColor(PropVal));
    if Prop.PropertyType.ToString='TBrushKind'   then   Result := TValue.From(StringToTBrushKind(PropVal));
    if Prop.PropertyType.ToString='TDeviceKind'  then   Result := TValue.From(StringToTDeviceKind(PropVal));
    if Prop.PropertyType.ToString='TTabOrder'    then   Result := TValue.From(StrToInt(PropVal));
    if Prop.PropertyType.ToString='Single'       then   Result := TValue.From(StrToSingle(PropVal));
    if Prop.PropertyType.ToString='TAnchors'     then   Result := TValue.From(StrToAnchors(PropVal));
    // Log_write('test.txt', Prop.PropertyType.ToString+' --  '+PropVal + '    '+Prop.PropertyType.QualifiedName );
end;


procedure TParse.SetObjEvent(const Prop:string;AInstance:TObject;Value:String);
var
  ctx:TRttiContext;
  pm       : TRttiProperty;
begin
      if not(Assigned(AInstance)) then Exit;
      ctx := TRttiContext.Create;
      try
        // Log_write('test.txt', Prop+' ==  '+Value );
        for pm in ctx.GetType(AInstance.ClassInfo).GetProperties do
        begin
          if CompareText(Prop,pm.Name)=0 then
           begin
             try
               if Assigned(AInstance) then
               begin
                    SetEvent(AInstance,pm,Prop,Value);
                    {
                    if pm.PropertyType.QualifiedName = 'System.Classes.TNotifyEvent' then
                    begin
                        pm.SetValue(AInstance,TValue.From<TNotifyEvent>(MyNotifyEvent) );
                    end;
                    }
               end;
             except
                // придумать обработку ошибок !!!
             end;
           end;
        end;
      finally
        ctx.Free;
      end;
end;

// https://stackoverrun.com/ru/q/1958550
procedure TParse.SetObjValueEx(const ObjPath:string;AInstance:TObject;Value:String);
Var
    c            : TRttiContext;
    Prop         : string;
    SubProp      : string;
    pm           : TRttiProperty;
    p            : TRttiProperty;
    ObjEdit          : TObject;
    AValue       : TValue;
begin
    if pos('.',ObjPath)>0 then
    begin
        Prop:=Copy(ObjPath,1,Pos('.',ObjPath)-1);
        SubProp:=Copy(ObjPath,Pos('.',ObjPath)+1);
        // if not(GetObjValueEx('Parent', AInstance ).ToString = '(empty)') then begin
        //     // ShowMessage(  GetObjValueEx('Parent', AInstance ).ToString );
        // end;
        // if Assigned((AInstance as TPresentedControl).Parent) then begin
        //    ShowMessage(Prop+'.'+SubProp+' = '+AValue.ToString+'      '+(AInstance as TPresentedControl).Parent.ToString);
        //  end;
        c := TRttiContext.Create;
        try
          for pm in c.GetType(AInstance.ClassInfo).GetProperties do
          begin
              if CompareText(Prop,pm.Name)=0 then
              begin
                 p := c.GetType(pm.PropertyType.Handle).GetProperty(SubProp);
                 if Assigned(p) then
                 begin
                   AValue := getConvertValue(p,Value);
                   if not AValue.IsEmpty then  begin
                     ObjEdit:=pm.GetValue(AInstance).AsObject;
                     if Assigned(ObjEdit) then begin
                        p.SetValue(ObjEdit,AValue);
                     end;
                   end;
                 end;
                 break;
              end;
          end;
        finally
          c.Free;
        end;
    end else begin
      Prop:=ObjPath;
      c := TRttiContext.Create;
      try
          for pm in c.GetType(AInstance.ClassInfo).GetProperties do
          begin
              if CompareText(Prop,pm.Name)=0 then
              begin
                AValue := getConvertValue(pm,Value);
                if not AValue.IsEmpty then  begin
                  if Assigned(AInstance) then
                     pm.SetValue(AInstance,AValue);
                end;
                   break;
              end;
          end;
        finally
        c.Free;
        end;
    end;
end;


function TParse.GetObjValueEx(const ObjPath:string;AInstance:TObject):TValue;
Var
    RttiContext            : TRttiContext;
    Prop         : string;
    SubProp      : string;
    PropObj      : TRttiProperty;
    PropSubObj   : TRttiProperty;
    Obj          : TObject;
begin
    if pos('.',ObjPath)>0 then
    begin
        Prop:=Copy(ObjPath,1,Pos('.',ObjPath)-1);
        SubProp:=Copy(ObjPath,Pos('.',ObjPath)+1);
        RttiContext := TRttiContext.Create;
        try
          for PropObj in RttiContext.GetType(AInstance.ClassInfo).GetProperties do
          if CompareText(Prop,PropObj.Name)=0 then
          begin
             PropSubObj := RttiContext.GetType(PropObj.PropertyType.Handle).GetProperty(SubProp);
             if Assigned(PropSubObj) then
             begin
               Obj:=PropObj.GetValue(AInstance).AsObject;
               if Assigned(Obj) then
                 Result:=PropSubObj.GetValue(Obj);
             end;
             break;
          end;
        finally
          RttiContext.Free;
        end;
    end else begin
      Prop:=ObjPath;
      RttiContext := TRttiContext.Create;
      try
          for PropObj in RttiContext.GetType(AInstance.ClassInfo).GetProperties do
          begin
              if CompareText(Prop,PropObj.Name)=0 then
              begin
                   if Assigned(AInstance) then
                     Result:=PropObj.GetValue(AInstance);
                 break;
              end;
          end;
        finally
          RttiContext.Free;
        end;
    end;
end;

function TParse.GetFullNameClass(className:String):String;
begin
   Result :='';
   if className='TButton' then begin Result :='FMX.StdCtrls.TButton'; exit; end;
   if className='TEdit' then begin Result :='FMX.Edit.TEdit'; exit; end;
   if className='TPanel' then begin Result :='FMX.StdCtrls.TPanel'; exit; end;
   if className='TLabel' then begin Result :='FMX.StdCtrls.TLabel'; exit; end;
   if className='TCheckBox' then begin Result :='FMX.StdCtrls.TCheckBox'; exit; end;
   if className='TRadioButton' then begin Result :='FMX.StdCtrls.TRadioButton'; exit; end;
   if className='TProgressBar' then begin Result :='FMX.StdCtrls.TProgressBar'; exit; end;
end;



procedure TParse.SetControlParent(obj, parent: TObject);
var
  ctx: TRttiContext;
  typ: TRttiType;
  prop: TRttiProperty;
begin
  typ := ctx.GetType(obj.ClassType);
  prop := typ.GetProperty('Parent');
  prop.SetValue(obj, parent);
end;

function TParse.GetControlParent(obj: TObject):TObject;
var
  ctx: TRttiContext;
  typ: TRttiType;
begin
  typ := ctx.GetType(obj.ClassType);
  Result :=typ.GetProperty('Parent');
end;



procedure TParse.DFM(var DFMtext: TStringList; var NumLine:Integer; CountBSobject:Integer; obj:TObject; objParent:TObject);
var
  line          : String;
  LenObj        : integer;  // количество пробелов до слова object
  LenEnd        : integer;  // количество пробелов до слова END
  objectName    : String;
  PropName      : String;
  PropVal       : String;
  tmp           : String;
  className     : String;
  classNameFull : string;
  C : TRttiContext;
  T : TRttiInstanceType;
  V : TValue;
  ctx           : TRttiContext;

begin
    while not ( NumLine = DFMtext.Count-2) do begin
        inc(NumLine);
        line:= DFMtext[NumLine];

        if pos('end',line)>0 then begin
          LenEnd := Length(copy(line,1, pos('end',line)-1));
          if CountBSobject = LenEnd then exit;
        end;

        // ctx := TRttiContext.Create;
        if Pos( 'object ', line)>0 then
        begin
           LenObj := Length(copy(line,1, pos('object ',line)-1));
           line:= copy(line,pos('object ',line)+Length('object '), Length(line));
           className:= copy(line,pos(': ',line)+Length(': '), Length(line));
           objectName:= copy(line,1,pos(': ',line)-Length(': ')+1);
           classNameFull:=GetFullNameClass(className);
           // если нет полного названи€ класса, тогда пропускаем объект со всеми детьми
           if classNameFull='' then
           begin
              while True do
              begin
                inc(NumLine);
                if ( NumLine = DFMtext.Count-2) then Break;
                line:= DFMtext[NumLine];
                LenEnd := Length(copy(line,1, pos('end',line)-1));
                if LenEnd = LenObj then Break; // если количество пробелов до слова 'end' равен количеству пробелов до слова 'object' выходим
              end;
             continue;
           end;
           t := ctx.FindType(classNameFull) as TRttiInstanceType;
           if not (t = nil) then begin
             T := (C.FindType(classNameFull) as TRttiInstanceType);
             if objParent = nil then
                V := T.GetMethod('Create').Invoke(T.metaClassType,[obj])
             else
                V := T.GetMethod('Create').Invoke(T.metaClassType,[objParent]);
             SetControlParent(V.AsObject,obj);
             SetObjValueEx('Name',V.AsObject,objectName)   ;
             (V.AsObject as TPresentedControl).Name := objectName;
             DFM(DFMtext,NumLine,LenObj,V.AsObject,nil);
           end;
           continue;
       end else begin
          PropVal  := copy(line,pos(' = ',line)+Length(' = '), Length(line));
          tmp := copy(line,1,pos(' = ',line)-1);
          PropName:= tmp.Replace(' ','');
          if copy(PropName,1,2)='On' then begin
              SetObjEvent(PropName,obj,PropVal);
          end else begin
              SetObjValueEx(PropName,obj,PropVal)   ;
          end;
       end;
        // ctx.Free;
        if NumLine = DFMtext.Count-2 then Break;
    end;
end;


end.
