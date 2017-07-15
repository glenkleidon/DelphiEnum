unit MiniTestFramework;

interface

uses SysUtils, windows, Variants;

Const
  PASS_FAIL: array[0..3] of string = ('PASS', 'SKIP', 'FAIL', 'ERR ');
  FOREGROUND_DEFAULT=7;
  SKIPPED = True;
  SKIP = True; //alternate

  DEFAULT_SCREEN_WIDTH=80;
  FOREGROUND_CYAN=3;
  FOREGROUND_YELLOW=6;
  FOREGROUND_PURPLE=5;

  clTitle = FOREGROUND_YELLOW;
  clError = FOREGROUND_RED;
  clPass  = FOREGROUND_GREEN;
  clMessage=FOREGROUND_CYAN;
  clDefault=FOREGROUND_DEFAULT;
  clSkipped=FOREGROUND_PURPLE;



Type
  TComparitorType = Variant;
  TTestCaseProcedure = Procedure();
  TTestSet = Record
    Execute: TTestCaseProcedure;
    TestClass: string;
    Skip: Boolean;
    ExpectedException: string;
  end;

var
  MiniTestCases : Array of TTestSet;

  SkippingSet,IgnoreSkip : boolean;

  ExpectedException, ExpectedSetException,
  CurrentTestClass, CurrentTestCase: string;
  TotalPassedTestCases : integer =0;
  TotalFailedTestCases : integer =0;
  TotalSkippedTestCases: integer =0;
  TotalErroredTestCases: integer =0;
  TotalSets            : integer =0;

  SetPassedTestCases, SetFailedTestCases, SetErrors, SetSkippedTestCases: integer;

Procedure Title(AText: string);

Procedure AddTestSet(ATestClass: string; AProcedure : TTestCaseProcedure;
    ASkipped:boolean=False; AExpectedException: string = '');
Procedure PrepareSet(AProcedure: TTestCaseProcedure);
Procedure FinaliseSet(AProcedure: TTestCaseProcedure);
Procedure FinalizeSet(AProcedure: TTestCaseProcedure);
Procedure RunTestSets;

Procedure NewTestCase(ACase: string; ATestClassName: string = '');
Procedure NewTestSet(AClassName: string; ASkipped: boolean=false);
Function  CheckIsEqual(AExpected, AResult: TComparitorType;
  AMessage: string = ''; ASkipped: boolean=false): boolean;
Function  CheckIsTrue(AResult: boolean; AMessage: string = ''; ASkipped: boolean=false): boolean;
Function  CheckIsFalse(AResult: boolean; AMessage: string = ''; ASkipped: boolean=false): boolean;
Function  CheckNotEqual(AResult1, AResult2: TComparitorType;
  AMessage: string = ''; ASkipped: boolean=false): boolean;
Procedure ExpectException(AExceptionClassName: string;AExpectForSet: boolean=false);
Procedure CheckException(AException: Exception);
Function  NotImplemented(AMessage: string=''):boolean;
Function  DontSkip:Boolean;
Function  TotalTests: integer;
Procedure TestSummary;
procedure ClassResults;
Function  ConsoleScreenWidth:integer;
Procedure Print(AText: String; AColour: smallint = FOREGROUND_DEFAULT);
Procedure PrintLn(AText: String; AColour: smallint = FOREGROUND_DEFAULT);

implementation

Type
  TCheckTestType = (cttComparison, cttSkip, cttException);

var
  SameTestCounter :integer = 0;
  LastTestCase: string;



///////////  SCREEN MANAGEMENT \\\\\\\\\\\\\\\\\

var
  Screen_width: Integer =-1;
  Console_Handle: THandle = 0;

Function  TotalTests: integer;
begin
  result := TotalPassedTestCases +
            TotalFailedTestCases +
            TotalSkippedTestCases +
            TotalErroredTestCases +
            SetPassedTestCases +
            SetFailedTestCases +
            SetSkippedTestCases +
            SetErrors;
end;

Function ConsoleHandle:THandle;
begin
  if Console_Handle=0 then
    Console_Handle := GetStdHandle(STD_OUTPUT_HANDLE);
  result := Console_Handle;
end;

procedure DoubleLine;
begin
  Println(stringofchar('=',ConsoleScreenWidth));
end;

procedure SingleLine;
begin
  Println(stringofchar('-',ConsoleScreenWidth));
end;

Procedure SetTextColour(AColour: SmallInt);
begin
  SetConsoleTextAttribute(ConsoleHandle,AColour);
end;

Function ConsoleScreenWidth:integer;
var lScreenInfo: TConsoleScreenBufferInfo;
begin
  if Screen_width=-1 then
  begin
    try
      GetConsoleScreenBufferInfo(ConsoleHandle,lScreenInfo);
      Screen_width := lScreenInfo.dwSize.X-2;
    except
      Screen_Width := DEFAULT_SCREEN_WIDTH;
    end;
  end;
  Result := Screen_Width;
end;

Procedure Print(AText: String; AColour: smallint = FOREGROUND_DEFAULT);
begin
  SetTextColour(AColour);
  Write(Atext);
  if Acolour<> FOREGROUND_DEFAULT then SetTextColour(FOREGROUND_DEFAULT);
end;

Procedure PrintLn(AText: String; AColour: smallint = FOREGROUND_DEFAULT);
begin
  Print(AText+#13#10, AColour);
end;

Procedure AddTestSet(ATestClass: string; AProcedure : TTestCaseProcedure;
  ASkipped: Boolean; AExpectedException: string);
var l:integer;
begin
   l := length(MiniTestCases);
   SetLength(MiniTestCases,l+1);
   MiniTestCases[l].Execute := AProcedure;
   MiniTestCases[l].TestClass := ATestClass;
   MiniTestCases[l].Skip := ASkipped;
   MiniTestCases[l].ExpectedException := AExpectedException;
end;

Procedure PrepareSet(AProcedure: TTestCaseProcedure);
begin
  AddTestSet('',AProcedure);
end;

Procedure FinaliseSet(AProcedure: TTestCaseProcedure);
begin
  AddTestSet('',AProcedure);
end;

Procedure FinalizeSet(AProcedure: TTestCaseProcedure);
begin
  // Americaniz(s)ed form
  FinaliseSet(AProcedure);
end;

Procedure RunTestSets;
var i,l: integer;
begin
  l := length(MiniTestCases);
  for i := 0 to l-1 do
  Try
    if MiniTestCases[i].TestClass<>'' then
      NewTestSet(MiniTestCases[i].TestClass,MiniTestCases[i].Skip);
    ExpectException(MiniTestCases[i].ExpectedException,true);
    MiniTestCases[i].Execute;
  except
    on e:exception do CheckException(e);
  end;
end;

Procedure Title(AText: string);
var PreSpace,PostSpace, TitleSpace:integer;
begin
  TitleSpace := ConsoleScreenWidth-4;
  PreSpace :=  trunc((TitleSpace-Length(AText))/2);
  PostSpace := TitleSpace-PreSpace-Length(AText);
  SetTextColour(clDefault);
  DoubleLine;
  Print(StringOfChar('=',PreSpace));
  Print('  ' + AText + '  ',clTitle);
  Println(StringOfChar('=',PostSpace));
  DoubleLine;
end;

function SetHasErrors: smallint;
begin
  Result := 0;
  if SetFailedTestCases+SetErrors>0 then result := 2
  else if SetSkippedTestCases>0 then result := 1;
end;

function RunHasErrors: smallint;
var lSetResult : smallint;
begin
  Result := 0;
  if (TotalFailedTestCases+TotalErroredTestCases>0) then result := 2
  else if TotalSkippedTestCases>0 then Result := 1;
  if result = 2  then exit;
  lSetResult := SetHasErrors;
  if lSetResult>result then result := lSetResult;
end;

Function ResultColour(AHasErrors: smallint):smallInt;
var lIntesity: byte;
begin
  case AHasErrors AND 3 of
    0:Result := clPass;
    1:Result := clSkipped;
  else Result := clError;
  end;
  lIntesity := AHasErrors and 255 and
      (BACKGROUND_INTENSITY or FOREGROUND_INTENSITY);
  result := result or lIntesity;
end;

procedure ClassResults;
begin

  if (SetPassedTestCases=0) and
     (SetFailedTestCases=0) and
     (SetSkippedTestCases=0) and
     (SetErrors=0)
  then exit;

  Println(
     format(' Results> Passed:%-5d Failed:%-5d Skipped:%-5d Errors:%-5d',[
              SetPassedTestCases,
              SetFailedTestCases,
              SetSkippedTestCases,
              SetErrors
              ]),
     ResultColour(SetHasErrors)
  );

  DoubleLine;
end;

Procedure TestSummary;
begin
  NewTestSet('');
  Println(
    format('Total Sets:%-5d Tests:%-5d Passed:%-5d Failed:%-5d Skipped:%-5d Errors:%-5d',[
              TotalSets-1, TotalTests,
              TotalPassedTestCases,TotalFailedTestCases,
              TotalSkippedTestCases, TotalErroredTestCases
    ]),
    ResultColour(RunHasErrors or FOREGROUND_INTENSITY)
  );
end;
/////////// END SCREEN MANAGEMENT \\\\\\\\\\\\\\\\\


/////////// TEST CASES  \\\\\\\\\\\\\\\\\

Procedure NewTestSet(AClassName: string; ASkipped: boolean);
var lHeading: string;
begin
  ClassResults;
  if AClassName<>'' then
  begin
    lHeading :=' Test Set:'+ AClassName;
    Println(lHeading,clTitle);
  end;

  inc(totalSets);
  inc(TotalPassedTestCases, SetPassedTestCases);
  Inc(TotalFailedTestCases, SetFailedTestCases);
  inc(TotalSkippedTestCases, SetSkippedTestCases);
  Inc(TotalErroredTestCases, SetErrors);
  SkippingSet := ASkipped;
  IgnoreSkip := false;
  ExpectedSetException := '';
  SetPassedTestCases := 0;
  SetFailedTestCases := 0;
  SetSkippedTestCases := 0;
  SetErrors := 0;
  SameTestCounter := 0;
  LastTestCase := '';
  CurrentTestCase:='';
  CurrentTestClass:=AClassName;
  ExpectedException := '';
end;

Procedure ExpectException(AExceptionClassName: string;AExpectForSet: boolean=false);
begin
  ExpectedException := '';
end;

function ValueAsString(AValue: TComparitorType): string;
var lType:  TVarType;
begin
  lType := varType(AValue);
  case lType of
    varEmpty : Result := 'Empty';
    varNull  : Result := 'null';
    varSingle,
    varDouble,
    varCurrency : Result := FloatToStr(AValue);
    varDate     : Result := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',Avalue);
    varBoolean : If (AValue) Then Result := 'True' else Result := 'False';

    varSmallint,
    varInteger,
    varVariant,
    varShortInt,
    varByte,
    varWord,
    varLongWord,
    {$IFDEF UNICODE}
     varUInt64,
    {$ENDIF}

    varInt64    : Result := IntToStr(AValue);

    {$IFDEF UNICODE}
      varUString,
    {$ENDIF}
    varOleStr,
    varStrArg,
    varString    : Result := AValue;

  else
    Result := 'Unsupported Type';
  end;

end;

Function CompareValues(AExpected, AResult : TComparitorType):boolean;
var lExpectedType,
    lResultType :  TVarType;
    lExpectedIsInteger,
    lExpectedIsNumber,
    lExpectedIsString,
    lResultIsInteger,
    lResultIsNumber,
    lResultIsString : Boolean;
begin
    Result := false;
    lExpectedType := VarType(AExpected);
    lResultType := VarType(AResult);

    if (lExpectedType = lResultType) then
    begin
      Result :=  (AExpected=AResult);
      exit;
    end;

    lResultIsInteger := lResultType in [varByte, varSmallint, varInteger, varShortInt
                                         ,varWord,varLongWord,varInt64];
    if (lExpectedType = VarBoolean) and
       (lResultIsInteger) then
    begin
      Result := (AExpected=(AResult=0));
      exit;
    end;

    lExpectedIsInteger := lExpectedType in [varByte, varSmallint, varInteger, varShortInt
                                             ,varWord,varLongWord,varInt64];

    if (lExpectedIsInteger and lResultIsInteger) then
    begin
      Result := varAsType(AExpected,varInt64)=VarAsType(Aresult,varInt64) ;
      exit;
    end;

    if (lResultType = VarBoolean) and (lExpectedIsInteger) then
    begin
      Result := (AExpected=0)=AResult;
      exit;
    end;

    lExpectedIsNumber := (lExpectedisInteger) or
       (lExpectedType in [varSingle,varDouble,varCurrency]);
    lResultIsNumber := (lResultIsInteger) or
       (lResultType in [varSingle,varDouble,varCurrency]);

    if (lExpectedIsNumber and lResultIsNumber) then
    begin
      result := double(AExpected)=double(AResult);
      exit;
    end;

    lExpectedIsString := (lExpectedType=varString) or
           (lExpectedType in [varOleStr, varStrArg]);
    lResultIsString := (lResultType=varString) or
           (lResultType in [varOleStr, varStrArg]);
    if (lExpectedIsString and lResultIsString) then
    begin
       result := AResult = AExpected;
       exit;
    end;
end;

Function Check(IsEqual: boolean; AExpected, AResult: TComparitorType;
  AMessage: string; ATestType: TCheckTestType): boolean;
var
  lMessage,lCounter: string;
  lResult: integer;
  Outcome: Boolean;
  lMessageColour: smallint;
begin
  Result := false;
  lMessageColour := clDefault;
  lResult := 0;
  try
    case ATestType Of
      cttSkip :
          begin
            lResult:=1;
            if Amessage='' then lMessage:=' Test Skipped'
             else lMessage := ' '+AMessage;
            lMessageColour := clSkipped;
            inc(SetSkippedTestCases);
            exit;
          end;
      cttException:
          begin
             if isEqual then
             begin
                lResult := 0;
                inc(SetPassedTestCases);
             end else
             begin
                lResult := 3;
                inc(SetErrors);
                lMessageColour := clMessage;
                lMessage := format('%s   Expected:<%s>%s   Actual  :<%s>',
                 [#13#10, ValueAsString(AExpected), #13#10, ValueAsString(AResult)])
             end;
             if AMessage='' then lMessage:= ' Exception.'
             else lMEssage := ' '+AMessage;
          end;
    else //case
      begin
        try
          lMessage := '';
          Outcome := CompareValues(AExpected,AResult);
          if IsEqual<>Outcome then
          begin
            lResult := 2;
            inc(SetFailedTestCases);
            if AMessage = '' then
            begin
              lMessageColour := clError;
              if isEqual then
                lMessage := format('%s   Expected:<%s>%s   Actual  :<%s>',
                 [#13#10, ValueAsString(AExpected), #13#10, ValueAsString(AResult)])
              else
                lMessage := format('%s   Expected outcomes to differ, but both returned %s%s',
                 [#13#10, ValueAsString(AExpected)]);
            end;
            exit;
          end;
          inc(SetPassedTestCases);
        except
          on e: exception do
          begin
            if (e.ClassName=ExpectedException) then
            begin
              // At this level, it will only be exceptions
              // for Variant type comparisons
              lResult := 0;
              inc(SetPassedTestCases);
            end else
            begin
              lResult := 2;
              lMessage := e.Message;
              inc(SetErrors);
            end;
          end;
        end;
      end; //case else
    end; //case
  finally
    if LastTestCase=CurrentTestCase then inc(SameTestCounter) else SameTestCounter:=1;
    LastTestCase := CurrentTestCase;
    if SameTestCounter=1 then lCounter := '' else lCounter := '-'+InttoStr(SameTestCounter);
    if CurrentTestCase = '' then
    begin
     CurrentTestCase:=copy('Test for '+CurrentTestClass,1,ConsoleScreenWidth-4);
     if lCounter='' then
     begin
      lCounter:='-1';
      LastTestCase := CurrentTestCase;
     end;
     ExpectedException := ExpectedSetException;
     IgnoreSkip := false;
    end;

    Print(format('  %s-',[PASS_FAIL[lResult]]),lMessageColour);
    Print(format('%s%s', [CurrentTestCase,lCounter]));
    Println(lMessage,lMessageColour);
    Result := (lResult=0);
  end;
end;

function TestTypeFromSkip(ASkipped: Boolean): TCheckTestType;
begin
  if (Not IgnoreSkip) and (ASkipped or SkippingSet) then
     Result := cttSkip else Result := cttComparison;
end;

Function DontSkip:Boolean;
begin
  IgnoreSkip := true;
  result := false;
end;

Function CheckIsEqual(AExpected, AResult: TComparitorType;
  AMessage: string = '';ASkipped: boolean=false): boolean;
begin
  Result := check(true,AExpected, AResult, Amessage,
              TestTypeFromSkip(ASkipped));
end;

Function CheckNotEqual(AResult1, AResult2: TComparitorType;
  AMessage: string; ASkipped: boolean): boolean;
Begin
  Result := check(false,AResult1, AResult2, Amessage,
                   TestTypeFromSkip(ASkipped));
end;

Function CheckIsTrue(AResult: boolean; AMessage: string;ASkipped: boolean): boolean;
begin
  Result := CheckIsEqual(True, AResult, AMessage,ASkipped);
end;

Function CheckisFalse(AResult: boolean; AMessage: string; ASkipped: boolean): boolean;
begin
  Result := CheckIsEqual(False, AResult,AMessage,ASkipped);
end;

Procedure CheckException(AException: Exception);
var lExpected: string;
begin
   lExpected := ExpectedException;
   if lExpected='' then lExpected := 'No Exceptions';
   Check(
     (AException.className=lExpected) or
     (AException.Message = lExpected),
      lExpected,
      AException.ClassName+':'+AException.Message,
      '',
      cttException);
end;

Function NotImplemented(AMessage: string = ''): boolean;
var lMessage: string;
begin
  if AMessage='' then lMessage:='Not Implemented'
    else lMessage := AMessage;
  Result := CheckisTrue(true,lMessage,Skipped);
end;


procedure NewTestCase(ACase: string; ATestClassName: string);
begin

  if (ATestClassName <> '') and
     (
       (ACase='') OR
       (CurrentTestClass<>ATestClassName)
     ) then NewTestSet(ATestClassName);

   if ACase <> '' then
    CurrentTestCase := ACase;
   ExpectedException := ExpectedSetException;
   IgnoreSkip := false;
end;

initialization
  {$IF CompilerVersion >= 20.0}
    system.ReportMemoryLeaksOnShutdown := True;
  {$IFEND}

end.
