unit Model.Classes;

interface

uses
  GenericAttributes;

type
  [Tabela('Region')]
  TRegion = Class
  private
    Fdescricao: String;
    Fid: Integer;
    procedure Setdescricao(const Value: String);
    procedure Setid(const Value: Integer);
  public
    [Campo('RegionID'), PK]
    property id : Integer read Fid write Setid;
    [Campo('RegionDescription')]
    property descricao : String read Fdescricao write Setdescricao;
  End;

implementation

{ TRegion }

procedure TRegion.Setdescricao(const Value: String);
begin
  Fdescricao := Value;
end;

procedure TRegion.Setid(const Value: Integer);
begin
  Fid := Value;
end;

end.
