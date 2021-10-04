unit GenericDAOConnection;

interface

uses
  System.JSON,
  System.Generics.Collections,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  Data.DB,
  FireDAC.Comp.Client,
  Firedac.DApt,
  Firedac.Phys.FB,
  Firedac.Phys.SQLite,
  Firedac.Phys.SQLiteDef,
  Firedac.Phys.FBDef,
  Firedac.Phys.MySQLDef,
  Firedac.Phys.MySQL,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI;

type
  TTypeConnection = (FireBird, SQLite);

var
  FConnList : TObjectList<TFDConnection>;
  FServer : String;
  FDatabase : String;
  FTypeConnection : TTypeConnection;

function Connected : Integer;
procedure Disconnected(IndexConn : Integer);

implementation

uses
  System.SysUtils;

function Connected : Integer;
var
  IndexConn : Integer;
begin
  if not Assigned(FConnList) then
    FConnList := TObjectList<TFDConnection>.Create;

  FConnList.Add(TFDConnection.Create(nil));
  IndexConn := Pred(FConnList.Count);

  FConnList.Items[IndexConn].Params.Database := FDatabase;

  if FDatabase = '' then
    raise Exception.Create('variable FDatabase must be informed!');

  case FTypeConnection of
    FireBird :
      begin
        if FServer = '' then
          raise Exception.Create('variable FServer must be informed!');

        FConnList.Items[IndexConn].Params.DriverID := 'FB';
        FConnList.Items[IndexConn].Params.UserName := 'sysdba';
        FConnList.Items[IndexConn].Params.Password := 'masterkey';
        FConnList.Items[IndexConn].Params.Add('Server='+FServer);
        FConnList.Items[IndexConn].Params.Add('Protocol=TCPIP');
      end;

    SQLite :
      begin
        FConnList.Items[IndexConn].Params.DriverID := 'SQLite';
        FConnList.Items[IndexConn].Params.Add('LockingMode=Normal');
      end;
  end;

  FConnList.Items[IndexConn].Connected;

  Result := IndexConn;
end;

procedure Disconnected(IndexConn : Integer);
begin
  FConnList.Items[IndexConn].Connected := false;
  FConnList.Items[IndexConn].Free;
  FConnList.TrimExcess;
end;

end.
