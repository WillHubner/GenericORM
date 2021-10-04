unit GenericDAO;

interface

uses
  System.JSON,
  System.Classes,
  System.Generics.Collections,

  REST.Json,

  GenericQuery,
  GenericInterfaces,
  GenericSQL,
  GenericRTTI,
  GenericPaginate;

type
  TGenericDAO<T: class, constructor> = class(TInterfacedObject, iGenericDAO<T>)
  private
    FQuery : iGenericQuery<T>;
    FParams : TDictionary<String, Variant>;
  public
    constructor Create;
    destructor Destroy; override;

    class function New : iGenericDAO<T>;

    function AddFilter(const aField : String; const aValue : Variant) : iGenericDAO<T>;

    function Open : TJSONValue; overload;
    function Open(const vID : Integer) : TJSONObject; overload;
    function Insert(aInstance : T) : TJSONObject; overload;
    function Insert(aInstance : TJSONObject) : TJSONObject; overload;
    function Update(aInstance : T) : TJSONObject; overload;
    function Update(aInstance : TJSONObject) : TJSONObject; overload;
    function Delete(const vID : Integer) : Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TGenericDAO<T> }

function TGenericDAO<T>.AddFilter(const aField : String; const aValue : Variant) : iGenericDAO<T>;
begin
  Result := Self;
  FParams.Add(aField, aValue);
end;

constructor TGenericDAO<T>.Create;
begin
  FQuery := TGenericQuery<T>.New;
  FParams := TDictionary<String, Variant>.Create;
end;

function TGenericDAO<T>.Delete(const vID: Integer): Boolean;
var
  vSQL, vPK : String;
begin
  TGenericSQL<T>.New.Delete(vSQL);

  Result := FQuery.SQL(vSQL).Param(vID).Execute;
end;

destructor TGenericDAO<T>.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TGenericDAO<T>.Insert(aInstance: TJSONObject): TJSONObject;
begin
  Result := Self.Insert(TJson.JsonToObject<T>(aInstance));
end;

function TGenericDAO<T>.Insert(aInstance: T): TJSONObject;
var
  vSQL : String;
begin
  TGenericSQL<T>.New.Insert(vSQL);

  FQuery.SQL(vSQL).FillParams(aInstance).Execute;

  vSQL := '';

  TGenericSQL<T>.New.LastRecord(vSQL);

  Result := FQuery.Clear.SQL(vSQL).ToJSONObject;
end;

class function TGenericDAO<T>.New: iGenericDAO<T>;
begin
  Result := Self.Create;
end;

function TGenericDAO<T>.Open(const vID: Integer): TJSONObject;
var
  vSQL, vPK : String;
begin
  TGenericSQL<T>.New.SelectID(vSQL, vPK);
  Result := FQuery.SQL(vSQL).Param(vPK, vID.ToString).ToJSONObject;
end;

function TGenericDAO<T>.Update(aInstance: TJSONObject): TJSONObject;
begin
  Result := Self.Update(TJson.JsonToObject<T>(aInstance));
end;

function TGenericDAO<T>.Update(aInstance: T): TJSONObject;
var
  aSQL : String;
  DictionaryFields : TDictionary<String, Variant>;
  aPK : String;
  aPkValue : Integer;
begin
  TGenericSQL<T>.New.Update(aSQL);

  FQuery.SQL(aSQL).FillParams(aInstance).Execute;

  DictionaryFields := TDictionary<String, Variant>.Create;

  TGenericRTTI<T>.New(aInstance).ListFields(DictionaryFields).PrimaryKey(aPK);

  aPkValue := DictionaryFields.Items[aPK];

  FQuery.Clear;

  Result := Self.Open(aPKValue);
end;

function TGenericDAO<T>.Open: TJSONValue;
var
  vSQL, vSQLCount, vKey : String;
  SQL : iGenericSQL<T>;

  vTotal : Integer;
  vPages : Double;

  vResult : TJSONArray;
begin
  SQL := TGenericSQL<T>.New;

  if not (LLimit = 0) then
    begin
      SQL.Paginate(LLimit, LPage);

      Result := TJSONObject.Create;
    end;

  if not (Length(FParams.ToArray) = 0) then
    begin
      for vKey in FParams.Keys.ToArray do
        SQL.Where(vKey);

      SQL.Select(vSQL);

      FQuery.SQL(vSQL);

      for vKey in FParams.Keys.ToArray do
        FQuery.Param(SQL.FieldClassToFieldSQL(vKey), Fparams.Items[vKey]);

      vResult := FQuery.ToJSONArray;

      if not (LLimit = 0) then
        begin
          TJSONObject(Result).AddPair('docs', vResult);

          SQL.Count(vSQLCount);

          FQuery.Clear().SQL(vSQLCount);

          for vKey in FParams.Keys.ToArray do
            FQuery.Param(SQL.FieldClassToFieldSQL(vKey), Fparams.Items[vKey]);

          vTotal := FQuery.AsInteger('N');

          vPages := vTotal / LLimit;

          if not ((vPages - Trunc(vPages)) = 0) then
            vPages := Trunc(vPages) + 1;

          TJSONObject(Result).AddPair('limit', TJSONNumber.Create(LLimit));
          TJSONObject(Result).AddPair('page', TJSONNumber.Create(LPage));
          TJSONObject(Result).AddPair('pages', TJSONNumber.Create(vPages));
          TJSONObject(Result).AddPair('total', TJSONNumber.Create(vTotal));
        end
      else
        Result := FQuery.ToJSONArray;
    end
  else
    begin
      SQL.Select(vSQL);

      FQuery.SQL(vSQL);

      vResult := FQuery.ToJSONArray;

      if not (LLimit = 0) then
        begin
          TJSONObject(Result).AddPair('docs', vResult);

          SQL.Count(vSQLCount);

          FQuery.Clear();
          FQuery.SQL(vSQLCount);

          vTotal := FQuery.AsInteger('N');
          vPages := vTotal / LLimit;

          if not ((vPages - Trunc(vPages)) = 0) then
            vPages := Trunc(vPages) + 1;

          TJSONObject(Result).AddPair('limit', TJSONNumber.Create(LLimit));
          TJSONObject(Result).AddPair('page', TJSONNumber.Create(LPage));
          TJSONObject(Result).AddPair('pages', TJSONNumber.Create(vPages));
          TJSONObject(Result).AddPair('total', TJSONNumber.Create(vTotal));
        end
      else
        Result := FQuery.ToJSONArray;
    end;
end;

end.
