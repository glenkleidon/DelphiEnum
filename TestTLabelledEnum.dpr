program TestTLabelledEnum;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Enum in 'Enum.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }

    Writeln('Using Class methods to get the label names of the static type..');


    SlType := MyOptionB;
    Writeln('Without Labels, MyOptionB is "' + slType+'"');


    SLType.Labels := TMyLabels;
    Writeln('With Labels, MyOptionB is "' + slType+'"');

   Writeln('Changing SLType to MyOptionC using string assignment...');
   SLType := 'Option C';
   OptionEnum :=SLType;
   s := SLType;

   if OptionEnum=MyOptionC then
     Writeln(format('Successfully Changed to "%s" (%d)',[s,ord(OptionEnum)]))
   else Writeln(format('Fail - Changed to "%s" (%d) instead.',[s,integer(SlType)]));

   Writeln('Checking for Type in a set with implict casting.');
   if SLType in [MyOptionA,MyOptionA] then writeln('Something went wrong')
     else writeln('Yep, Stype is '+SLType);

   SLType :='option a';
   Writeln('Changing to "option a"  (string assignment)  shows "'+slType+'"');

   SLType := 'MyOptionB';
   Writeln('Changing to "MyOptionB" (string assignment)  shows "'+slType+'"');

   SLType := 2;
   Writeln('Changing to "2"         (integer assignment) shows "'+slType+'"');

   SLType := MyOptionA;
   Writeln('Changing to MyOptionA   (Static assignment)  shows "'+slType+'"');
   Writeln('Static Name of "'+slType+'" is "'+slType.ValueName+'"');



   readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
