unit Model.Connection;

interface

uses
  GenericConnection, GenericTypes;

procedure Config;

implementation

procedure Config;
begin
  GenericConnection.FTypeConnection := SQLite;
  GenericConnection.FDatabase := 'C:\Users\Public\Documents\Embarcadero\Studio\21.0\Samples\data\FDDemo.sdb';
end;

initialization
  Config;

end.
