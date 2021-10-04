unit GenericAttributes;

interface

uses
  System.RTTI, System.Variants, System.Classes;
type
  Tabela = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(aName: string);
    property Name: string read FName;
  end;

  Campo = class(TCustomAttribute)
  private
    FName: string;
  public
    Constructor Create(aName: string);
    property Name: string read FName;
  end;

  Display = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const aName: string);
    property Name: string read FName write FName;
  end;

  PK = class(TCustomAttribute)
  end;

  FK = class(TCustomAttribute)
  end;

  NotNull = class(TCustomAttribute)
  end;

  Ignore = class(TCustomAttribute)
  end;

  AutoInc = class(TCustomAttribute)
  end;

  NumberOnly = class(TCustomAttribute)
  end;

implementation

{ Tabela }

constructor Tabela.Create(aName: string);
begin
  FName := aName;
end;

{ Campo }

constructor Campo.Create(aName: string);
begin
  FName := aName;
end;

{ Display }

constructor Display.Create(const aName: string);
begin
  FName := aName;
end;

end.
