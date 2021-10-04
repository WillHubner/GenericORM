unit GenericQuery;

interface

uses
  Data.DB,

  System.JSON,
  System.Classes,
  System.Generics.Collections,

  GenericConnection,
  GenericInterfaces,
  GenericDataSetToJSON,
  GenericDataSetToJSONUtil,
  GenericRTTI,

  FireDAC.Comp.Client,
  FireDAC.Stan.Param;


type
  TGenericQuery<T : Class, constructor> = class(TInterfacedObject, iGenericQuery<T>)
  private
    FIndexConnection : Integer;
    FQuery : TFDQuery;
    FSQL: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    class function New : iGenericQuery<T>;

    function SQL(vSQL : String) : iGenericQuery<T>;
    function Clear : iGenericQuery<T>;
    function FillParams(aInstance : T) : iGenericQuery<T>;

    function Param(aKey : String; aValue : String) : iGenericQuery<T>; overload;
    function Param(aValue : Variant) : iGenericQuery<T>; overload;

    function Execute : Boolean;
    function ToJSONArray : TJSONArray;
    function ToJSONObject : TJSONObject;
    function AsInteger(aField : String) : Integer;
    function AsString(aField : String) : String;
    function RecordCount : Integer;
  end;

implementation

uses
  System.SysUtils;

{ TGenericQuery }

function TGenericQuery<T>.AsInteger(aField: String): Integer;
begin
  Result := 0;

  if FSQL.Text = '' then
    raise Exception.Create('SQL não informado!');

  FQuery.Open;

  if FQuery.RecordCount > 0 then
    Result := FQuery.FieldByName(aField).AsInteger;
end;

function TGenericQuery<T>.AsString(aField: String): String;
begin
  Result := '';

  if FSQL.Text = '' then
    raise Exception.Create('SQL não informado!');

  FQuery.Open;

  if FQuery.RecordCount > 0 then
    Result := FQuery.FieldByName(aField).AsString;
end;

function TGenericQuery<T>.Clear: iGenericQuery<T>;
begin
  Result := Self;
  FQuery.Close;
  FQuery.SQL.Clear;
  FSQL.Clear;
end;

constructor TGenericQuery<T>.Create;
begin
  FQuery := TFDQuery.Create(nil);
  FIndexConnection := GenericConnection.Connected;
  FQuery.Connection := GenericConnection.FConnList.Items[FIndexConnection];
  FSQL := TStringList.Create;
end;

destructor TGenericQuery<T>.Destroy;
begin
  FQuery.Close;
  FQuery.Free;
  FSQL.Free;
  GenericConnection.Disconnected(FIndexConnection);

  inherited;
end;

function TGenericQuery<T>.Execute: Boolean;
begin
  if FSQL.Text = '' then
    raise Exception.Create('SQL não informado!');

  try
    FQuery.ExecSQL;

    Result := True;
  except
    Result := False;
  end;
end;

function TGenericQuery<T>.FillParams(aInstance: T): iGenericQuery<T>;
var
  Key : String;
  DictionaryFields : TDictionary<String, Variant>;
begin
  DictionaryFields := TDictionary<String, Variant>.Create;

  TGenericRTTI<T>.New(aInstance).ListFields(DictionaryFields);

  FQuery.Prepare;

  try
    for Key in DictionaryFields.Keys do
      Self.Param(Key, DictionaryFields.Items[Key]);

  finally
    FreeAndNil(DictionaryFields);
  end;
end;

class function TGenericQuery<T>.New: iGenericQuery<T>;
begin
  Result := Self.Create;
end;

function TGenericQuery<T>.Param(aValue: Variant): iGenericQuery<T>;
begin
  Result := Self;
  FQuery.Params[0].Value := aValue;
end;

function TGenericQuery<T>.Param(aKey: String; aValue: String): iGenericQuery<T>;
begin
  Result := Self;

  if FQuery.Params.FindParam(aKey) <> nil then
    FQuery.ParamByName(aKey).AsString := aValue;
end;

function TGenericQuery<T>.ToJSONArray: TJSONArray;
begin
  Result := TJSONArray.Create;

  if FSQL.Text = '' then
    raise Exception.Create('SQL não informado!');

  FQuery.Open;

  if FQuery.RecordCount > 0 then
    Result := TDataSetToJSON<T>.New.DataSetToJSONArray(FQuery);
end;

function TGenericQuery<T>.ToJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;

  if FSQL.Text = '' then
    raise Exception.Create('SQL não informado!');

  FQuery.Open;

  if FQuery.RecordCount > 0 then
    Result := TDataSetToJSON<T>.New.DataSetToJSONObject(FQuery);
end;

function TGenericQuery<T>.RecordCount: Integer;
begin
  if FSQL.Text = '' then
    raise Exception.Create('SQL não informado!');

  if not FQuery.Active then
    FQuery.Open;

  result := FQuery.RecordCount;
end;

function TGenericQuery<T>.SQL(vSQL : String) : iGenericQuery<T>;
begin
  Result := Self;

  FSQL.Add(vSQL);

  FQuery.SQL.Text := FSQL.Text;
end;

end.



