unit Routes;

interface

uses
  Horse,

  GenericDAO,
  GenericInterfaces,

  System.JSON,
  System.SysUtils,

  Model.Classes;

procedure Registry;

procedure GET(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure GETID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure POST(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure PUT(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure DELETE(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure Registry;
begin
  THorse.Get('/region', GET);
  THorse.Get('/region/:id', GETID);
  THorse.Post('/region', POST);
  THorse.Put('/region', PUT);
  THorse.Delete('/region/:id', DELETE);
end;

procedure GET(Req: THorseRequest; Res: THorseResponse; Next: TProc);
const
  Fields  : array  [1..2] of string = ('id', 'descricao');
var
  DAO : iGenericDAO<TRegion>;
  Field,
  aValue : String;
begin
  DAO := TGenericDAO<TRegion>.New;

  for Field in Fields do
    if Req.Query.TryGetValue(Field, aValue) then
      DAO.AddFilter(Field, aValue);

  Res.Send<TJSONValue>(DAO.Open);
end;

procedure GETID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send<TJSONObject>(TGenericDAO<TRegion>.New.Open(Req.Params['id'].ToInteger));
end;

procedure POST(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send<TJSONObject>(TGenericDAO<TRegion>.New.Insert(Req.Body<TJSONObject>));
end;

procedure PUT(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send<TJSONObject>(TGenericDAO<TRegion>.New.Update(Req.Body<TJSONObject>));
end;

procedure DELETE(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  if TGenericDAO<TRegion>.New.Delete(Req.Params['id'].ToInteger) then
    Res.Send('').Status(THTTPStatus.NoContent)
  else
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('msg', 'Deletado com sucesso!'));
end;

end.
