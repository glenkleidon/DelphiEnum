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
    Writeln('===================================================================================');
    Writeln('The Record Type "TLabelledEnum" is a Generic Record Type that adds Label support ');
    Writeln('to existing Enumerated types.');
    Writeln('By creating a Type of "TLabelledEnum<TYourType>" it is very simple to add one or');
    Writeln('more labels to each TYourType Option and then use the Text label, integer value or');
    Writeln('named identifier interchangably in your code. Eg: '#13#10);
    Writeln('-----------------------------------------------------------------------------------');
    Writeln('     Uses  Enum;');
    Writeln('     const TMyLabels : TArray<String> = [''Option A'', ''Option B'', ''Option C''];');
    Writeln('     type  TMyType  = (MyOptionA, MyOptionB, MyOptionC)');
    Writeln('           TLabelledMyType = TLabelledEnum<TMyType>;');
    Writeln('     var   OptionEnum = TLabelledMyType;');
    Writeln('           ThisType: integer;');
    Writeln('     Begin');
    Writeln('       TLabelledMyType.SetTypeLabels(TMyLabels); //<=Add labels to your type');
    Writeln('       OptionEnum:=MyOptionA;                    //<=Assign the value as normal');
    Writeln('       ThisType:=OptionEnum;                     //<=OR Assign to integers');
    Writeln('       if (OptionEnum = ''option a'') then         //<=OR Use labels instead ');
    Writeln('              OptionEnum := ThisType+1;          //<=AND Assign from integers');
    Writeln('       Writeln(''OptionEnum is "'' +               //<=And use it as a string');
    Writeln('              +OptionEnum+''"'');                  // Shows: OptionEnum is "Option B"');
    Writeln('     End.');
    Writeln('-----------------------------------------------------------------------------------');
    Writeln('Execute above Example:');

    TLabelledMyType.SetTypeLabels(TMyLabels);
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
