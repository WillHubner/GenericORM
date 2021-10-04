program Demo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  GenericConnection in '..\GenericConnection.pas',
  Model.Classes in 'Model.Classes.pas',
  GenericDataSetToJSON in '..\GenericDataSetToJSON.pas',
  GenericDataSetToJSONUtil in '..\GenericDataSetToJSONUtil.pas',
  GenericDAO in '..\GenericDAO.pas',
  GenericInterfaces in '..\GenericInterfaces.pas',
  GenericAttributes in '..\GenericAttributes.pas',
  GenericSQL in '..\GenericSQL.pas',
  GenericRTTI in '..\GenericRTTI.pas',
  GenericRTTIHelper in '..\GenericRTTIHelper.pas',
  GenericQuery in '..\GenericQuery.pas',
  Model.Connection in 'Model.Connection.pas',
  GenericTypes in '..\GenericTypes.pas',
  GenericPaginate in '..\GenericPaginate.pas',
  Routes in 'Routes.pas';

begin
  THorse
    .Use(Jhonson)
    .Use(GenericPaginateMiddleware);

  ReportMemoryLeaksOnShutdown := True;

  Routes.Registry;

  THorse.Listen(9000);
end.

