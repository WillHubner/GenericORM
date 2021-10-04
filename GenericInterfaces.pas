unit GenericInterfaces;

interface

uses
  System.JSON,
  System.Generics.Collections;

type
  iGenericDAO<T : Class> = interface
    ['{15466469-AE9B-41AE-A05F-7443BB035E6B}']
    function Open : TJSONValue; overload;
    function Open(const vID : Integer) : TJSONObject; overload;
    function Insert(aInstance : T) : TJSONObject; overload;
    function Insert(aInstance : TJSONObject) : TJSONObject; overload;
    function Update(aInstance : T) : TJSONObject; overload;
    function Update(aInstance : TJSONObject) : TJSONObject; overload;
    function Delete(const vID : Integer) : Boolean;
    function AddFilter(const aField : String; const aValue : Variant) : iGenericDAO<T>;
  end;

  iGenericSQL<T> = interface
    ['{896EE252-3081-4D9B-97B9-416F957FC94A}']
    function Select(var aSQL : String) : iGenericSQL<T>;
    function SelectID(var aSQL : String; var aPK : String) : iGenericSQL<T>;
    function Count(var aSQL : String) : iGenericSQL<T>;
    function Update(var aSQL : String) : iGenericSQL<T>;
    function Insert(var aSQL : String) : iGenericSQL<T>;
    function LastRecord(var aSQL : String) : iGenericSQL<T>;
    function Delete(var aSQL : String) : iGenericSQL<T>;
    function Where(const aKey : String) : iGenericSQL<T>;
    function FieldClassToFieldSQL(const aKey : String) : String;
    function Paginate(const aLimit : Integer; const aPage : Integer) : iGenericSQL<T>;
  end;

  iGenericRTTI<T : class> = interface
    ['{A07FDABC-0A35-4715-9C91-2F6EBEB1ED61}']
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

  iGenericQuery<T : Class> = interface
    ['{5E6736F2-469E-4FB1-8167-E2601054A465}']
    function Clear : iGenericQuery<T>;
    function SQL(vSQL : String) : iGenericQuery<T>;
    function Param(vKey : String; aValue : String) : iGenericQuery<T>; overload;
    function Param(aValue : Variant) : iGenericQuery<T>; overload;
    function FillParams(aInstance : T) : iGenericQuery<T>;

    function Execute : Boolean;
    function RecordCount : Integer;

    function AsInteger(aField : String) : Integer;
    function AsString(aField : String) : String;
    function ToJSONArray : TJSONArray;
    function ToJSONObject : TJSONObject;
  end;


implementation

end.
