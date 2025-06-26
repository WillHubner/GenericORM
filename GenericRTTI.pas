unit GenericRTTI;

interface

uses
  GenericInterfaces,
  GenericAttributes,
  GenericRTTIHelper,

  Data.DB,
  TypInfo,

  System.RTTI,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

type
  TGenericRTTI<T : Class, constructor> = class(TInterfacedObject, iGenericRTTI<T>)
  private
    FInstance : T;

    function __FloatFormat( aValue : String ) : Currency;
  public
    constructor Create(aInstance : T);
    destructor Destroy; override;

    class function New(aInstance : T) : iGenericRTTI<T>;
    class procedure DictionaryFieldClass(var aDictionary : TDictionary<string, string>);
    class procedure DictionaryClassField(var aDictionary : TDictionary<string, string>);
    class procedure DictionaryClassType(var aDictionary : TDictionary<String, TTypeKind>);

    function ListFields(var aDictionary : TDictionary<string, variant>) : iGenericRTTI<T>;
    function TableName(var aTableName: String): iGenericRTTI<T>;
    function ClassName (var aClassName : String) : iGenericRTTI<T>;
    function Update (var aUpdate : String) : iGenericRTTI<T>;
    function Where (var aWhere : String) : iGenericRTTI<T>;
    function Fields (var aFields : String) : iGenericRTTI<T>;
    function FieldsInsert (var aFields : String) : iGenericRTTI<T>;
    function Param (var aParam : String) : iGenericRTTI<T>;
    function PrimaryKey(var aPK : String) : iGenericRTTI<T>;
  end;

implementation

uses
  System.Variants;

{ TGenericRTTI<T> }

function TGenericRTTI<T>.ClassName(var aClassName: String): iGenericRTTI<T>;
begin

end;

constructor TGenericRTTI<T>.Create(aInstance : T);
begin
  FInstance := aInstance;
end;

destructor TGenericRTTI<T>.Destroy;
begin

  inherited;
end;

class procedure TGenericRTTI<T>.DictionaryClassField(
  var aDictionary: TDictionary<string, string>);
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
      begin
        if prpRtti.IsIgnore then
          Continue;
        aDictionary.Add(prpRtti.DisplayName, prpRtti.FieldName);
      end;
  finally
    ctxRtti.Free;
  end;
end;

class procedure TGenericRTTI<T>.DictionaryClassType(
  var aDictionary: TDictionary<String, TTypeKind>);
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
      begin
        if prpRtti.IsIgnore then
          Continue;

        aDictionary.Add(prpRtti.FieldName, prpRtti.DataType.TypeKind);
      end;
  finally
    ctxRtti.Free;
  end;
end;

class procedure TGenericRTTI<T>.DictionaryFieldClass(
  var aDictionary: TDictionary<string, string>);
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
      begin
        if prpRtti.IsIgnore then
          Continue;
        aDictionary.Add(prpRtti.FieldName, prpRtti.DisplayName);
      end;
  finally
    ctxRtti.Free;
  end;
end;

function TGenericRTTI<T>.Fields(var aFields: String): iGenericRTTI<T>;
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Result := Self;
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
    begin
      if not prpRtti.IsIgnore then
        aFields := aFields + prpRtti.FieldName + ', ';
    end;
  finally
    aFields := Copy(aFields, 0, Length(aFields) - 2) + ' ';
    ctxRtti.Free;
  end;
end;

function TGenericRTTI<T>.FieldsInsert(var aFields: String): iGenericRTTI<T>;
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Result := Self;
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
    begin
      if prpRtti.IsAutoInc then
        Continue;
      if prpRtti.IsIgnore then
        Continue;
      aFields := aFields + prpRtti.FieldName + ', ';
    end;
  finally
    aFields := Copy(aFields, 0, Length(aFields) - 2) + ' ';
    ctxRtti.Free;
  end;
end;

function TGenericRTTI<T>.ListFields(
  var aDictionary: TDictionary<string, variant>): iGenericRTTI<T>;
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Result := Self;
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
    begin
      if prpRtti.IsIgnore then
        Continue;
      case prpRtti.PropertyType.TypeKind of
        tkInteger, tkInt64:
          begin
            if prpRtti.EhChaveEstrangeira then
            begin
              if prpRtti.GetValue(Pointer(FInstance)).AsInteger = 0 then
                aDictionary.Add(prpRtti.FieldName, Null)
              else
                aDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsInteger);
            end
            else
              aDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsInteger);
          end;
        tkFloat       :
        begin
          if prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TDateTime) then
            aDictionary.Add(prpRtti.FieldName, StrToDateTime(prpRtti.GetValue(Pointer(FInstance)).ToString))
          else
          if prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TDate) then
              aDictionary.Add(prpRtti.FieldName, StrToDate(prpRtti.GetValue(Pointer(FInstance)).ToString))
          else
          if prpRtti.GetValue(Pointer(FInstance)).TypeInfo = TypeInfo(TTime) then
            aDictionary.Add(prpRtti.FieldName, StrToTime(prpRtti.GetValue(Pointer(FInstance)).ToString))
          else
            aDictionary.Add(prpRtti.FieldName, __FloatFormat(prpRtti.GetValue(Pointer(FInstance)).ToString));
        end;
        tkWChar,
        tkLString,
        tkWString,
        tkUString,
        tkString      : aDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsString);
        tkVariant     : aDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsVariant);
      else
          aDictionary.Add(prpRtti.FieldName, prpRtti.GetValue(Pointer(FInstance)).AsString);
      end;
    end;
  finally
    ctxRtti.Free;
  end;
end;

class function TGenericRTTI<T>.New(aInstance: T): iGenericRTTI<T>;
begin
  Result := Self.Create(aInstance);
end;

function TGenericRTTI<T>.Param(var aParam: String): iGenericRTTI<T>;
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Result := Self;
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
    begin
      if prpRtti.IsIgnore then
        Continue;
      if prpRtti.IsAutoInc then
        Continue;
      aParam  := aParam + ':' + prpRtti.FieldName + ', ';
    end;
  finally
    aParam := Copy(aParam, 0, Length(aParam) - 2) + ' ';
    ctxRtti.Free;
  end;
end;

function TGenericRTTI<T>.PrimaryKey(var aPK: String): iGenericRTTI<T>;
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Result := Self;
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
    begin
      if prpRtti.EhChavePrimaria then
        aPK := prpRtti.FieldName;
    end;
  finally
    ctxRtti.Free;
  end;
end;

function TGenericRTTI<T>.TableName(var aTableName: String): iGenericRTTI<T>;
var
  vInfo   : PTypeInfo;
  vCtxRtti: TRttiContext;
  vTypRtti: TRttiType;
begin
  Result := Self;
  vInfo := System.TypeInfo(T);
  vCtxRtti := TRttiContext.Create;
  try
    vTypRtti := vCtxRtti.GetType(vInfo);

    if vTypRtti.Tem<Tabela> then
      aTableName := vTypRtti.GetAttribute<Tabela>.Name;
  finally
    vCtxRtti.Free;
  end;
end;

function TGenericRTTI<T>.Update(var aUpdate: String): iGenericRTTI<T>;
var
  ctxRtti   : TRttiContext;
  typRtti   : TRttiType;
  prpRtti   : TRttiProperty;
  Info     : PTypeInfo;
begin
  Result := Self;
  Info := System.TypeInfo(T);
  ctxRtti := TRttiContext.Create;
  try
    typRtti := ctxRtti.GetType(Info);
    for prpRtti in typRtti.GetProperties do
    begin
      if prpRtti.IsIgnore then
        Continue;

      if prpRtti.IsAutoInc then
        Continue;

      aUpdate := aUpdate + prpRtti.FieldName + ' = :' + prpRtti.FieldName + ', ';
    end;
  finally
    aUpdate := Copy(aUpdate, 0, Length(aUpdate) - 2) + ' ';
    ctxRtti.Free;
  end;
end;

function TGenericRTTI<T>.Where(var aWhere: String): iGenericRTTI<T>;
begin

end;

function TGenericRTTI<T>.__FloatFormat(aValue: String): Currency;
begin
  while Pos('.', aValue) > 0 do
    delete(aValue,Pos('.', aValue),1);
  Result := StrToCurr(aValue);
end;

end.
