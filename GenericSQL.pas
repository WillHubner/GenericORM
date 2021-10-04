unit GenericSQL;

interface

uses
  GenericRTTI,
  GenericTypes,
  GenericInterfaces,
  GenericConnection,

  System.Generics.Collections;

type
  TGenericSQL<T : class, constructor> = class(TInterfacedObject, iGenericSQL<T>)
  private
    DictionaryFields : TDictionary<String, String>;

    FWhere : String;

    FLimit : Integer;
    FPage : Integer;
  public
    constructor Create;
    destructor Destroy; override;

    class function New : iGenericSQL<T>;

    function Paginate(const aLimit : Integer; const aPage : Integer) : iGenericSQL<T>;

    function Select(var aSQL : String) : iGenericSQL<T>;
    function SelectID(var aSQL : String; var aPK : String) : iGenericSQL<T>;
    function Count(var aSQL : String) : iGenericSQL<T>;
    function Insert(var aSQL : String) : iGenericSQL<T>;
    function Update(var aSQL : String) : iGenericSQL<T>;
    function Delete(var aSQL : String) : iGenericSQL<T>;
    function Where(const aKey : String) : iGenericSQL<T>;
    function LastRecord(var aSQL : String) : iGenericSQL<T>;
    function FieldClassToFieldSQL(const aKey : String) : String;
  end;

implementation

uses
  System.SysUtils;

{ TGenericSQL<T> }

function TGenericSQL<T>.Count(var aSQL: String): iGenericSQL<T>;
var
  aFields, aClassName : String;
begin
  Result := Self;

  TGenericRTTI<T>.New(nil)
    .Fields(aFields)
    .TableName(aClassName);

  aSQL := aSQL + 'SELECT count(*) as N FROM ' + aClassName + ' ';

//  if Trim(FJoin) <> '' then
//    aSQL := aSQL + ' ' + FJoin + ' ';
  if Trim(FWhere) <> '' then
    aSQL := aSQL + FWhere;
//  if Trim(FGroupBy) <> '' then
//    aSQL := aSQL + ' GROUP BY ' + FGroupBy;
//  if Trim(FOrderBy) <> '' then
//    aSQL := aSQL + ' ORDER BY ' + FOrderBy;
end;

constructor TGenericSQL<T>.Create;
begin
  DictionaryFields := TDictionary<String, String>.Create;
  FLimit := 0;
  FPage := 0;
  FWhere := '';
end;

function TGenericSQL<T>.Delete(var aSQL: String): iGenericSQL<T>;
var
  aClassName, aPK : String;
begin
  Result := Self;

  TGenericRTTI<T>.New(nil)
    .TableName(aClassName)
    .PrimaryKey(aPK);

  aSQL := aSQL + 'DELETE FROM ' + aClassName;
  aSQL := aSQL + ' WHERE ' + aPK + ' = :'+aPK;
end;

destructor TGenericSQL<T>.Destroy;
begin
  DictionaryFields.Free;

  inherited;
end;

function TGenericSQL<T>.FieldClassToFieldSQL(const aKey: String): String;
begin
  if Length(DictionaryFields.ToArray) = 0 then
    TGenericRTTI<T>.DictionaryClassField(DictionaryFields);

  Result := DictionaryFields.Items[aKey];
end;

function TGenericSQL<T>.Insert(var aSQL: String): iGenericSQL<T>;
var
  aClassName, aFields, aParam : String;
begin
  Result := Self;
    TGenericRTTI<T>.New(nil)
      .TableName(aClassName)
      .FieldsInsert(aFields)
      .Param(aParam);

    aSQL := aSQL + 'INSERT INTO ' + aClassName;
    aSQL := aSQL + ' (' + aFields + ') ';
    aSQL := aSQL + ' VALUES (' + aParam + ');';
end;

function TGenericSQL<T>.LastRecord(var aSQL: String): iGenericSQL<T>;
var
  aClassName, aPK, aFields : String;
begin
  Result := Self;
  TGenericRTTI<T>.New(nil)
    .TableName(aClassName)
    .Fields(aFields)
    .PrimaryKey(aPK);

  case GenericConnection.FTypeConnection of
    Firebird:
    begin
      aSQL := aSQL + 'select first(1) '+aFields;
      aSQL := aSQL + ' from '+ aClassName;
      aSQL := aSQL + ' order by ' + aPK + ' desc';
    end;
    MySQL, SQLite:
    begin
      aSQL := aSQL + 'select '+aFields;
      aSQL := aSQL + ' from '+ aClassName;
      aSQL := aSQL + ' order by ' + aPK + ' desc limit(1)';
    end;
  end;
end;

class function TGenericSQL<T>.New: iGenericSQL<T>;
begin
  Result := Self.Create;
end;

function TGenericSQL<T>.Paginate(const aLimit, aPage: Integer): iGenericSQL<T>;
begin
  Result := Self;

  FLimit := aLimit;
  FPage := aPage;
end;

function TGenericSQL<T>.Select(var aSQL: String): iGenericSQL<T>;
var
  aFields, aClassName : String;
begin
  Result := Self;

  TGenericRTTI<T>.New(nil)
    .Fields(aFields)
    .TableName(aClassName);

  aSQL := aSQL + 'SELECT ';

  if FLimit <> 0 then
    case GenericConnection.FTypeConnection of
      Firebird: aSQL := aSQL + ' FIRST '+FLimit.ToString + ' SKIP ' + IntToStr((FPAGE - 1)*FLimit);
    end;

  aSQL := aSQL + ' ' + aFields;

  aSQL := aSQL + ' FROM ' + aClassName;

//  if Trim(FJoin) <> '' then
//    aSQL := aSQL + ' ' + FJoin + ' ';
  if Trim(FWhere) <> '' then
    aSQL := aSQL + FWhere;
//  if Trim(FGroupBy) <> '' then
//    aSQL := aSQL + ' GROUP BY ' + FGroupBy;
//  if Trim(FOrderBy) <> '' then
//    aSQL := aSQL + ' ORDER BY ' + FOrderBy;

  if FLimit <> 0 then
    case GenericConnection.FTypeConnection of
      SQLite, MySQL: aSQL := aSQL + ' LIMIT '+FLimit.ToString + ' OFFSET ' + IntToStr((FPAGE - 1)*FLimit);
    end;
end;

function TGenericSQL<T>.SelectID(var aSQL, aPK: String): iGenericSQL<T>;
var
  aFields, aClassName : String;
begin
  Result := Self;

  TGenericRTTI<T>.New(nil)
    .Fields(aFields)
    .TableName(aClassName)
    .PrimaryKey(aPK);

  aSQL := aSQL + ' SELECT ' + aFields;
  aSQL := aSQL + ' FROM ' + aClassName;
  aSQL := aSQL + ' WHERE ' + aPK + ' = :' + aPK;
end;

function TGenericSQL<T>.Update(var aSQL: String): iGenericSQL<T>;
var
  ClassName, aUpdate, aPK : String;
begin
  Result := Self;

  TGenericRTTI<T>.New(nil)
    .TableName(ClassName)
    .Update(aUpdate)
    .PrimaryKey(aPK);

  aSQL := aSQL + 'UPDATE ' + ClassName;
  aSQL := aSQL + ' SET ' + aUpdate;
  aSQL := aSQL + ' WHERE ' + aPK + ' = :'+aPK;
end;

function TGenericSQL<T>.Where(const aKey : String) : iGenericSQL<T>;
var
  aField : String;
begin
  Result := Self;

  if Length(DictionaryFields.ToArray) = 0 then
    TGenericRTTI<T>.DictionaryClassField(DictionaryFields);

  aField := DictionaryFields.Items[aKey];

  if Pos('WHERE', FWhere) > 0 then
    FWhere := FWhere + ' AND ('+aField+' = :'+aField+')'
  else
    FWhere := FWhere + ' WHERE ('+aField+' = :'+aField+')';
end;

end.
