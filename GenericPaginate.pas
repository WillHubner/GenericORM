unit GenericPaginate;

interface

uses
  Horse;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
function GenericPaginateMiddleware: THorseCallback;

var
  LLimit : Integer;
  LPage : Integer;

implementation

uses
  System.SysUtils;

function GenericPaginateMiddleware: THorseCallback;
begin
  Result := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  aLimit, aPage: string;
begin
  if Req.Headers['X-Paginate'] = 'true' then
    begin
      if not Req.Query.TryGetValue('limit', aLimit) then
        aLimit := '25';
      if not Req.Query.TryGetValue('page', aPage) then
        aPage := '1';

      LLimit := aLimit.ToInteger;
      LPage := aPage.ToInteger;
    end
  else
    begin
      LLimit := 0;
      LPage := 0;
    end;

  Next;
end;

end.
