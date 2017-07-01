program TestTLabelledEnum;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Rtti,
  Enum in 'Enum.pas',
  MiniTestFramework in 'MiniTestFramework.pas';

Const
      TMyLabels : TArray<String> =
        ['Option A', 'Option B', 'Option C'];
  Type
      TMyType  = (MyOptionA, MyOptionB, MyOptionC);
      TLabelledMyType = TLabelledEnum<TMyType>;

procedure Label_of_static_Type_Passes;
var StaticNames : TArray<String>;
begin
  NewTestSet('Get Static Types using GetEnumNameList');
  StaticNames :=Enum.GetEnumNameList(TypeHandle(TMyTYpe));
  SetTestCase('GetEnumNameList returns 3 Values');
  CheckIsEqual(3,length(StaticNames));
  SetTestCase('GetEnumNameList Array elements match MyLabels');
  CheckIsEqual(StaticNames[0],'MyOptionA');
  CheckIsEqual(StaticNames[1],'MyOptionB');
  CheckIsEqual(StaticNames[2],'MyOptionC');
end;

procedure Without_Labels_Labelled_Enums_match_Static_types;
var s: string;
    lMyType : TLabelledMyType;
begin
  NewTestSet('Without Labels, Lablled Enum Implict String cast matches Static Values');
  // do not use implict cast to set the type here.
  lMyType.Enum := TMyType.MyOptionA;
  SetTestCase('Implicit Cast of TMyType.MyOptionA to String matches "MyOptionA"');
  s := lMyType;
  CheckIsEqual(s,'MyOptionA');

  lMyType.Enum := TMyType.MyOptionB;
  SetTestCase('Implicit Cast of TMyType.MyOptionB to String matches "MyOptionB');
  s := lMyType;
  CheckIsEqual(s,'MyOptionB');

  lMyType.Enum := TMyType.MyOptionC;
  SetTestCase('Implicit Cast of TMyType.MyOptionC to String matches "MyOptionC"');
  s := lMyType;
  CheckIsEqual(s,'MyOptionC');

end;

procedure Implicit_Static_Type_Assignment_Assigns_Values;
var s: string;
    lMyType : TLabelledMyType;
begin
  NewTestSet('Implicit Static Type Casting Assigns expected Values');
  // do not use implict cast to set the type here.
  lMyType := TMyType.MyOptionA;
  SetTestCase('Implicit Cast of TMyType.MyOptionA to String matches "MyOptionA"');
  s := lMyType;
  CheckIsEqual(s,'MyOptionA');

  lMyType := TMyType.MyOptionB;
  SetTestCase('Implicit Cast of TMyType.MyOptionB to String matches "MyOptionB');
  s := lMyType;
  CheckIsEqual(s,'MyOptionb');

  lMyType := TMyType.MyOptionC;
  SetTestCase('Implicit Cast of TMyType.MyOptionC to String matches "MyOptionC"');
  s := lMyType;
  CheckIsEqual(s,'MyOptionc');

end;


procedure Implicit_String_Assignment_Assigns_Values;
var staticType : TMyType;
    lMyType : TLabelledMyType;
begin
  NewTestSet('Without Labels Implicit String Casting Assigns expected Values');
  // do not use implict cast to set the type here.

  SetTestCase('Implicit Cast of lowercase string matches TMyType options');

  SetTestCase('Implicit Cast of lowercase string matches TMyType options');
  lMyType := 'myoptionb';
  staticType := TMyType.MyOptionB;
  CheckIsEqual(Ord(StaticType),Ord(lMyType.Enum));

  lMyType := 'myoptionc';
  staticType := TMyType.MyOptionC;
  CheckIsEqual(Ord(StaticType),Ord(lMyType.Enum));

  lMyType := 'myoptiona';
  staticType := TMyType.MyOptionA;
  CheckIsEqual(Ord(StaticType),Ord(lMyType.Enum));


end;



begin
  try
    Title('MiniTest - Test cases for TLabelledEnum');
    Label_of_static_Type_Passes;
    Without_Labels_Labelled_Enums_match_Static_types;
    Implicit_Static_Type_Assignment_Assigns_Values;
    Implicit_String_Assignment_Assigns_Values;


{
    Writeln('Using Class methods to get the label names of the static type');



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

 }
   TestSummary;

   if sameText(Paramstr(1),'/p') then ReadLn;


   ExitCode := TotalErrors+TotalFailedTestCases;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
