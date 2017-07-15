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

      TMyAlternateLabels: TArray<String> =
        ['Option 1', 'Option 2', 'Option 3'];

  ALTERNATE_CONTEXT ='AlternateContext';

  Type
      TMyType  = (MyOptionA, MyOptionB, MyOptionC);
      TLabelledMyType = TLabelledEnum<TMyType>;

procedure Label_of_static_Type_Passes;
var StaticNames : TArray<String>;
begin
  NewTestSet('Get Static Types using GetEnumNameList');
  StaticNames :=Enum.GetEnumNameList(TypeHandle(TMyTYpe));
  NewTestCase('GetEnumNameList returns 3 Values');
  CheckIsEqual(3,length(StaticNames));
  NewTestCase('GetEnumNameList Array elements match MyLabels');
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
  NewTestCase('Implicit Cast of TMyType.MyOptionA to String matches "MyOptionA"');
  s := lMyType;
  CheckIsEqual(s,'MyOptionA');

  lMyType.Enum := TMyType.MyOptionB;
  NewTestCase('Implicit Cast of TMyType.MyOptionB to String matches "MyOptionB');
  s := lMyType;
  CheckIsEqual(s,'MyOptionB');

  lMyType.Enum := TMyType.MyOptionC;
  NewTestCase('Implicit Cast of TMyType.MyOptionC to String matches "MyOptionC"');
  s := lMyType;
  CheckIsEqual(s,'MyOptionC');

end;

procedure Implicit_Static_Type_Assignment_Assigns_Values;
var s: string;
    lMyType : TLabelledMyType;
begin
  NewTestSet('Implicit Static Type Casting Assigns expected Values');

  lMyType := TMyType.MyOptionA;
  NewTestCase('Implicit Cast of TMyType.MyOptionA to String matches "MyOptionA"');
  s := lMyType;
  CheckIsEqual(s,'MyOptionA');

  lMyType := TMyType.MyOptionB;
  NewTestCase('Implicit Cast of TMyType.MyOptionB to String matches "MyOptionB');
  s := lMyType;
  CheckIsEqual(s,'MyOptionB');

  lMyType := TMyType.MyOptionC;
  NewTestCase('Implicit Cast of TMyType.MyOptionC to String matches "MyOptionC"');
  s := lMyType;
  CheckIsEqual(s,'MyOptionC');

end;

procedure Implicit_String_Assignment_Assigns_Values;
var staticType : TMyType;
    lMyType : TLabelledMyType;
begin
  NewTestSet('Without Labels Implicit String Casting Assigns expected Values');

  NewTestCase('Implicit Cast of lowercase string matches TMyType options');

  NewTestCase('Implicit Cast of lowercase string matches TMyType options');
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

Procedure Static_Class_Function_AsString_Works_as_expected;
var s: string;
begin
  NewTestSet('Without labels Static Class function returns correct Identifiers');

  s := TLabelledMyType(TMyType.MyOptionA);
  checkIsEqual('MyOptionA',s);

  s := TLabelledMyType(TMyType.MyOptionB);
  checkIsEqual('MyOptionB',s);

  s := TLabelledMyType(TMyType.MyOptionC);
  checkIsEqual('MyOptionC',s);

end;

procedure Assigning_Labels_assigns_alternate_labels;
var lMyType : TLabelledMyType;
    lLabels : TArray<string>;
    s: string;
begin
  NewTestSet('Assigning Labels assigns alternate labels');
  lMyType.Labels := TMyLabels;

  lLabels := GetEnumAliasList(lMyTYpe.InternalTypeInfo);

  checkisEQual(3,length(lLabels));

  s := lLabels[0];
  checkIsEqual('Option A',s);

  s := lLabels[1];
  checkIsEqual('Option B',s);

  s := lLabels[2];
  checkIsEqual('Option C',s);

end;
Procedure Implicit_Labelled_String_Assignment_Label_or_Identifier_Assigns_Values;
var lMyType : TLabelledMyType;
begin
  NewTestSet('Correct value assigned using label or Identifier');
  lMyType := 'Option A';
  checkIsTrue(TMyType.MyOptionA=lMyType.enum);
  lMyType := 'MyOptionb';
  checkIstrue(TMyType.MyOptionB=lMyType.enum);
  lMyType := 'option c';
  checkIsTrue(TMyType.MyOptionC=lMyType.enum);
  lMyType := 'MYOPTIONA';
  checkIsTrue(TMyType.MyOptionA=lMyType.enum);
end;

Procedure Static_Class_Function_Labelled_AsString_returns_labels_as_expected;
var s: string;
begin
  NewTestSet('Static Class Function As String Return Labels as Expected');

  s := TLabelledMyType(TMyType.MyOptionA);
  checkIsEqual('Option A',s);

  s := TLabelledMyType(TMyType.MyOptionB);
  checkIsEqual('Option B',s);

  s := TLabelledMyType(TMyType.MyOptionC);
  checkIsEqual('Option C',s);
end;

Procedure Add_second_Set_of_Labels_With_Different_context_Adds_independently;
var lNewLabels,
    lOldLabels,
    lOriginalLabels : TArray<string>;
    i: integer;
begin
  NewTestSet('A Second Set of Labels can set Independently');

  lOriginalLabels := TLabelledMyType.GetTypeLabels();
  TLabelledMyType.SetTypeLabels(TMyAlternateLabels, ALTERNATE_CONTEXT);
  lOldLabels := TLabelledMyType.GetTypeLabels();
  lNewLabels := TLabelledMyType.GetTypeLabels(ALTERNATE_CONTEXT);
  for i := 0 to 2 do
  begin
    CheckIsEqual(LOriginalLabels[i],lOldLabels[i]);
    CheckIsEqual(TMyAlternateLabels[i],LNewLabels[i]);
  end;
end;

procedure Remove_independently_removes_Second_set_Of_Labels;
var lLabels,
    lOriginalLabels : TArray<string>;
    i: integer;
    lMyType : TLabelledMyType;
begin
  NewTestSet('Removing Second set of Labels does not affect default');
  lOriginalLabels := TLabelledMyType.GetTypeLabels();
  TLabelledMyType.ClearTypeLabels(ALTERNATE_CONTEXT);
  lLabels := TLabelledMyType.GetTypeLabels();
  for i := 0 to 2 do
    CheckIsEqual(LOriginalLabels[i],lLabels[i]);

  NewTestCase('Original Labels Can Assign Enum');
  lMyType := 'Option c';
  checkIsTrue(TMyType.MyOptionC=lMyType.enum);

  NewTestSet('Second set of Labels no longer Accessible');
  lLabels := TLabelledMyType.GetTypeLabels(ALTERNATE_CONTEXT);
  CheckIsEqual(0,length(lLabels));

  lMyType := 'Option 2';
  checkisFalse(TMyType.MyOptionB=lMyType.enum);

  lMyType := 'Option 1';
  checkisFalse(TMyType.MyOptionA=lMyType.enum);

end;

procedure Use_Multiple_Contexts_works_as_Expected;
var i: integer;
    lMyType1, lMyType2 : TLabelledMyType;
begin
  NewTestSet('Two Contexts work As Expected');
  TLabelledMyType.SetTypeLabels(TMyAlternateLabels, ALTERNATE_CONTEXT);
  lMyType2.Context := ALTERNATE_CONTEXT;

  for i := 0 to 2 do
  begin
    lmyType1 := i;
    lmyType2 := i;
    NewTestCase('Label '+i.ToString+' for mytype1 <> myType2');
    CheckIsfalse(lmyType1+''=lmyType2+'');
    NewTestCase('Label '+i.ToString+' for mytype2 = Expected Label');
    CheckIsEqual(TMyAlternateLabels[i],lmyType2+'');
  end;

  NewTestCase('Changing Context Changes Expected Label');
  lMyType1.Context := ALTERNATE_CONTEXT;
  for i := 0 to 2 do
  begin
    lmyType1 := i;
    lmyType2 := i;
    NewTestCase('Label '+i.ToString+' for mytype1 <> myTyp2');
    CheckIsTrue(lmyType1+''=lmyType2+'');
    NewTestCase('Label '+i.ToString+' for mytype2 = Expected Label');
    CheckIsEqual(TMyAlternateLabels[i],lmyType2+'');
  end;

end;

begin
  try
    Title('MiniTest - Test cases for TLabelledEnum');
    Label_of_static_Type_Passes;
    Without_Labels_Labelled_Enums_match_Static_types;
    Implicit_Static_Type_Assignment_Assigns_Values;
    Implicit_String_Assignment_Assigns_Values;
    Static_Class_Function_AsString_Works_as_expected;

    // Set Labels
    Assigning_Labels_assigns_alternate_labels;
    Implicit_Labelled_String_Assignment_Label_or_Identifier_Assigns_Values;
    Static_Class_Function_Labelled_AsString_returns_labels_as_expected;

    // Label Context
    Add_second_Set_of_Labels_With_Different_context_Adds_independently;
    Remove_independently_removes_Second_set_Of_Labels;
    Use_Multiple_Contexts_works_as_Expected;


    TestSummary;

    if sameText(Paramstr(1),'/p') then ReadLn;


    ExitCode := TotalErroredTestCases+TotalFailedTestCases;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
