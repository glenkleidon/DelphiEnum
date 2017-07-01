program Selfdescribing;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Enum in 'Enum.pas';


  const TMyLabels : TArray<String> =
        ['Option A', 'Option B', 'Option C'];
  Type
      TMyType  = (MyOptionA, MyOptionB, MyOptionC);
      TLabelledMyType = TLabelledEnum<TMyType>;

var OptionEnum : TLabelledMyType;
    ThisType: integer;
begin
  try

    Writeln('DEMO - Using the Generic Enum.TLabelledEnum Type');
    Writeln('================================================');
    Writeln('The Record Type "TLabelledEnum" is a thread safe, leakproof Generic Record Type');
    Writeln('implemented as a Helper for enumerated types. ');
    Writeln('It allows implict type casting to and from static type names, string and integers.');
    Writeln('Allows Code such as: '#13#10);
    Writeln('----------------------------------------------------------------------------------'#13#10);
    Writeln('     Uses  Enum;');
    Writeln('     const TMyLabels : TArray<String> = [''Option A'', ''Option B'', ''Option C''];');
    Writeln('     type  TMyType  = (MyOptionA, MyOptionB, MyOptionC)');
    Writeln('           TLabelledMyType = TLabelledEnum<TMyType>;');
    Writeln('     var   OptionEnum = TLabelledMyType;');
    Writeln('     Begin');
    Writeln('       OptionEnum.Labels:=TMyLabels;  ');
    Writeln('       OptionEnum:=MyOptionA;  ');
    Writeln('       ThisType:=OptionEnum;');
    Writeln('       if (OptionEnum = ''option a'') then OptionEnum := ThisType+1;');
    Writeln('       Writeln(''OptionEnum is "''+OptionEnum+''"''); // Shows: OptionEnum is "Option B"');
    Writeln('     End.'#13#10);
    Writeln('-----------------------------------------------------------------------------------'#13#10);

    Writeln('Execute above Example:');

    OptionEnum.Labels:=TMyLabels;
    OptionEnum:=MyOptionA;
    ThisType:=OptionEnum;
    if (OptionEnum = 'option a') then OptionEnum := ThisType+1;
    Writeln('OptionEnum is "'+OptionEnum+'"'); // Shows: OptionEnum is "Option B"
    Readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
