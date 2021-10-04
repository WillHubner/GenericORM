unit GenericDataSetToJSON;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.DateUtils,
  System.NetEncoding,
  System.TypInfo,
  System.Generics.Collections,
  Data.SqlTimSt,
  Data.FmtBcd,
  Data.DB, GenericRTTI;

type
  EDataSetToJSONException = class(Exception);

  TBooleanFieldType = (bfUnknown, bfBoolean, bfInteger);
  TDataSetFieldType = (dfUnknown, dfJSONObject, dfJSONArray);

  iDataSetToJSON<T : class> = Interface
    ['{425BAE9D-927B-42BB-BC48-165F051A085C}']
    function DataSetToJSONObject(DataSet : TDataSet) : TJSONObject;
    function DataSetToJSONArray(DataSet : TDataSet) : TJSONArray;
  End;

  TDataSetToJSON<T : class, constructor> = Class(TInterfacedObject, iDataSetToJSON<T>)
  public
    constructor Create;
    destructor Destroy; override;

    class function New : iDataSetToJSON<T>;

    function DataSetToJSONObject(DataSet : TDataSet) : TJSONObject;
    function DataSetToJSONArray(DataSet : TDataSet) : TJSONArray;
  End;

implementation

uses
  GenericDataSetToJSONUtil;

{ TDataSetToJSON<T> }

constructor TDataSetToJSON<T>.Create;
begin

end;

function TDataSetToJSON<T>.DataSetToJSONArray(DataSet : TDataSet) : TJSONArray;
var
  bookMark: TBookmark;
begin
  Result := nil;
  if Assigned(dataSet) and (not dataSet.IsEmpty) then
    try
      Result := TJSONArray.Create;
      bookMark := dataSet.Bookmark;
      dataSet.First;
      while not dataSet.Eof do
      begin
        Result.AddElement(DataSetToJSONObject(dataSet));
        dataSet.Next;
      end;
    finally
      if dataSet.BookmarkValid(bookMark) then
        dataSet.GotoBookmark(bookMark);
      dataSet.FreeBookmark(bookMark);
    end;
end;

function TDataSetToJSON<T>.DataSetToJSONObject(DataSet : TDataSet) : TJSONObject;
var
  i: Integer;
  key : string;
  timeStamp: TSQLTimeStamp;
  nestedDataSet: TDataSet;
  dft: TDataSetFieldType;
  bft: TBooleanFieldType;
  ms: TMemoryStream;
  ss: TStringStream;
  DictionaryFields : TDictionary<String, String>;
  P : TParams;
begin
  Result := TJSONObject.Create;

  DictionaryFields := TDictionary<String, String>.Create;

  TGenericRTTI<T>.DictionaryFieldClass(DictionaryFields);

  try
    if Assigned(dataSet) and (not dataSet.IsEmpty) then
    begin
      for i := 0 to Pred(dataSet.FieldCount) do
      begin
        if dataSet.Fields[i].Visible then
        begin
          key := DictionaryFields.Items[dataSet.Fields[i].FieldName];
          case dataSet.Fields[i].DataType of
            TFieldType.ftBoolean:
              begin
                bft := TBooleanFieldType(BooleanFieldToType(TBooleanField(dataSet.Fields[i])));
                case bft of
                  bfUnknown, bfBoolean: Result.AddPair(key, BooleanToJSON(dataSet.Fields[i].AsBoolean));
                  bfInteger: Result.AddPair(key, TJSONNumber.Create(dataSet.Fields[i].AsInteger));
                end;
              end;
            TFieldType.ftInteger, TFieldType.ftSmallint, TFieldType.ftShortint:
              Result.AddPair(key, TJSONNumber.Create(dataSet.Fields[i].AsInteger));
            TFieldType.ftLongWord, TFieldType.ftAutoInc:
              begin
                if not dataSet.Fields[i].IsNull then
                  Result.AddPair(key, TJSONNumber.Create(dataSet.Fields[i].AsWideString))
                else
                  Result.AddPair(key, TJSONNull.Create);
              end;
            TFieldType.ftLargeint:
              Result.AddPair(key, TJSONNumber.Create(dataSet.Fields[i].AsLargeInt));
            TFieldType.ftSingle, TFieldType.ftFloat:
              Result.AddPair(key, TJSONNumber.Create(dataSet.Fields[i].AsFloat));
            ftString, ftWideString, ftMemo, ftWideMemo:
              begin
                if not dataSet.Fields[i].IsNull then
                  Result.AddPair(key, TJSONString.Create(dataSet.Fields[i].AsWideString))
                else
                  Result.AddPair(key, TJSONNull.Create);
              end;
            TFieldType.ftDate:
              begin
                if not dataSet.Fields[i].IsNull then
                  Result.AddPair(key, TJSONString.Create(DateToISODate(dataSet.Fields[i].AsDateTime)))
                else
                  Result.AddPair(key, TJSONNull.Create);
              end;
            TFieldType.ftTimeStamp, TFieldType.ftDateTime:
              begin
                if not dataSet.Fields[i].IsNull then
                  Result.AddPair(key, TJSONString.Create(DateTimeToISOTimeStamp(dataSet.Fields[i].AsDateTime)))
                else
                  Result.AddPair(key, TJSONNull.Create);
              end;
            TFieldType.ftTime:
              begin
                if not dataSet.Fields[i].IsNull then
                begin
                  timeStamp := dataSet.Fields[i].AsSQLTimeStamp;
                  Result.AddPair(key, TJSONString.Create(SQLTimeStampToStr('hh:nn:ss', timeStamp)));
                end
                else
                  Result.AddPair(key, TJSONNull.Create);
              end;
            TFieldType.ftCurrency:
              begin
                if not dataSet.Fields[i].IsNull then
                  Result.AddPair(key, TJSONString.Create(FormatCurr('0.00##', dataSet.Fields[i].AsCurrency)))
                else
                  Result.AddPair(key, TJSONNull.Create);
              end;
            TFieldType.ftFMTBcd, TFieldType.ftBCD:
              begin
                if not dataSet.Fields[i].IsNull then
                  Result.AddPair(key, TJSONNumber.Create(BcdToDouble(dataSet.Fields[i].AsBcd)))
                else
                  Result.AddPair(key, TJSONNull.Create);
              end;
            TFieldType.ftDataSet:
              begin
                dft := TDataSetFieldType(DataSetFieldToType(TDataSetField(dataSet.Fields[i])));
                nestedDataSet := TDataSetField(dataSet.Fields[i]).NestedDataSet;
                case dft of
                  dfJSONObject:
                    Result.AddPair(key, DataSetToJSONObject(nestedDataSet));
                  dfJSONArray:
                    Result.AddPair(key, DataSetToJSONArray(nestedDataSet));
                end;
              end;
            TFieldType.ftGraphic, TFieldType.ftBlob, TFieldType.ftStream:
              begin
                ms := TMemoryStream.Create;
                try
                  TBlobField(dataSet.Fields[I]).SaveToStream(ms);
                  ms.Position := 0;
                  ss := TStringStream.Create;
                  try
                    TNetEncoding.Base64.Encode(ms, ss);
                    Result.AddPair(key, TJSONString.Create(ss.DataString));
                  finally
                    ss.Free;
                  end;
                finally
                  ms.Free;
                end;
              end;
          else
            raise EDataSetToJSONException.CreateFmt('Cannot find type for field "%s"', [key]);
          end;
        end;
      end;
    end;

  finally
    FreeAndNil(DictionaryFields);
  end;
end;

destructor TDataSetToJSON<T>.Destroy;
begin

  inherited;
end;

class function TDataSetToJSON<T>.New: iDataSetToJSON<T>;
begin
  Result := Self.Create;
end;

end.
