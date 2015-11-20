program Alignment_M1_M2_New_Misha;

uses
  Forms,
  Alignment_Main_M1_M2_New in 'Alignment_Main_M1_M2_New.pas' {Aligment};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TAligment, Aligment);
  Application.Run;
end.
