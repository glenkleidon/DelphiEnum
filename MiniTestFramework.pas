unit MiniTestFramework;


interface

uses System.SysUtils,
  System.Generics.collections,
  System.rtti;

Const
  PASS_FAIL: array[0..2] of string = ('PASS', 'SKIP', 'FAIL');
  FOREGROUND_DEFAULT=7;
  SKIPPED = True;

var
  CurrentTestClass, CurrentTestCase: string;
  TotalPassedTestCases : integer =0;
  TotalFailedTestCases : integer =0;
  TotalSkippedTestCases: integer =0;
  TotalErrors          : integer =0;
  TotalSets            : integer =0;

  SetPassedTestCases, SetFailedTestCases, SetErrors, SetSkippedTestCases: integer;

Procedure Title(AText: string);
Procedure SetTestCase(ACase: string; ATestClassName: string = '');
Function  CheckIsEqual(AExpected, AResult: TValue;
  AMessage: string = ''; ASkipped: boolean=false): boolean;
Function  CheckIsTrue(AResult: boolean; AMessage: string = ''; ASkipped: boolean=false): boolean;
Function  CheckIsFalse(AResult: boolean; AMessage: string = ''; ASkipped: boolean=false): boolean;
Function  CheckNotEqual(AResult1, AResult2: TValue;
  AMessage: string = ''; ASkipped: boolean=false): boolean;
Function  NotImplemented(AMessage: string=''):boolean;
Procedure TestSummary;
procedure ClassResults;
Procedure NewTestSet(AClassName: string);
Function ConsoleScreenWidth:integer;
Procedure Print(AText: String; AColour: smallint = FOREGROUND_DEFAULT);
Procedure PrintLn(AText: String; AColour: smallint = FOREGROUND_DEFAULT);

implementation
uses windows;

var
  SameTestCounter :integer = 0;
  LastTestCase: string;


///////////  SCREEN MANAGEMENT \\\\\\\\\\\\\\\\\
const
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

var
  Screen_width: Integer =-1;
  Console_Handle: THandle = 0;



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

Procedure Title(AText: string);
var PreSpace,PostSpace, TitleSpace:integer;
begin
  TitleSpace := ConsoleScreenWidth-4;
  PreSpace :=  trunc((TitleSpace-AText.Length)/2);
  PostSpace := TitleSpace-PreSpace-AText.Length;
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
  if (TotalFailedTestCases+TotalErrors>0) then result := 2
  else if TotalSkippedTestCases>0 then Result := 1;
  if result = 2  then exit;
  lSetResult := SetHasErrors;
  if lSetResult>result then result := lSetResult;
end;

Function ResultColour(AHasErrors: smallint):smallInt;
begin
  case AHasErrors of
    0:Result := clPass;
    1:Result := clSkipped;
  else Result := clError;
  end;
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
    format('Total Sets:%-5d Passed:%-5d Failed:%-5d Skipped:%-5d Errors:%-5d',[
              TotalSets-1, TotalPassedTestCases,
              TotalFailedTestCases,TotalSkippedTestCases, TotalErrors]
    ),
    ResultColour(RunHasErrors or BACKGROUND_INTENSITY)
  );
end;
/////////// END SCREEN MANAGEMENT \\\\\\\\\\\\\\\\\


/////////// TEST CASES  \\\\\\\\\\\\\\\\\

Procedure NewTestSet(AClassName: string);
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
  Inc(TotalErrors, SetErrors);
  SetPassedTestCases := 0;
  SetFailedTestCases := 0;
  SetSkippedTestCases := 0;
  SetErrors := 0;
  SameTestCounter := 0;
  LastTestCase := '';
  CurrentTestCase:='';
  CurrentTestClass:=AClassName;

end;

Function Check(IsEqual: boolean; AExpected, AResult: TValue;
  AMessage: string; ASkipped: boolean): boolean;
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
    if ASkipped then
    begin
      lResult:=1;
      if Amessage='' then lMessage:='Test Skipped'
       else lMessage := ' '+AMessage;
      lMessageColour := clSkipped;
      inc(SetSkippedTestCases);
      exit;
    end;
    try
      lMessage := '';
      Outcome := AExpected.ToString = AResult.ToString;
      if IsEqual<>Outcome then
      begin
        lResult := 2;
        inc(SetFailedTestCases);
        if AMessage = '' then
        begin
          lMessageColour := clMessage;
          if isEqual then
            lMessage := format('%s   Expected:<%s>%s   Actual  :<%s>',
             [#13#10, AExpected.ToString, #13#10, AResult.ToString])
          else
            lMessage := format('%s   Expected outcomes to differ, but both returned %s%s',
             [#13#10, AExpected.ToString]);
        end;
      end;
      inc(SetPassedTestCases);
    except
      on e: exception do
      begin
        lResult := 2;
        lMessage := e.Message;
        inc(SetErrors);
      end;
    end;
  finally
    if LastTestCase=CurrentTestCase then inc(SameTestCounter) else SameTestCounter:=1;
    LastTestCase := CurrentTestCase;
    if SameTestCounter=1 then lCounter := '' else lCounter := '-'+SameTestCounter.ToString;
    if CurrentTestCase = '' then
    begin
     CurrentTestCase:=copy('Test for '+CurrentTestClass,1,ConsoleScreenWidth-4);
     if lCounter='' then
     begin
      lCounter:='-1';
      LastTestCase := CurrentTestCase;
     end;

    end;

    Print(format('  %s-',[PASS_FAIL[lResult]]),lMessageColour);
    Print(format('%s%s', [CurrentTestCase,lCounter]));
    Println(lMessage,lMessageColour);
    Result := (lResult=0);
  end;
end;

Function CheckIsEqual(AExpected, AResult: TValue;
  AMessage: string = '';ASkipped: boolean=false): boolean;
begin
  Result := check(true,AExpected, AResult, Amessage, ASkipped);
end;

Function CheckNotEqual(AResult1, AResult2: TValue;
  AMessage: string; ASkipped: boolean): boolean;
begin
  Result := check(false,AResult1, AResult2, Amessage, ASkipped);
end;

Function CheckIsTrue(AResult: boolean; AMessage: string;ASkipped: boolean): boolean;
begin
  Result := CheckIsEqual(True, AResult, AMessage,ASkipped);
end;

Function CheckisFalse(AResult: boolean; AMessage: string; ASkipped: boolean): boolean;
begin
  Result := CheckIsEqual(False, AResult,AMessage,ASkipped);
end;

Function NotImplemented(AMessage: string = ''): boolean;
var lMessage: string;
begin
  if AMessage='' then lMessage:='Not Implemented'
    else lMessage := AMessage;
  Result := CheckisTrue(true,lMessage,Skipped);
end;


procedure SetTestCase(ACase: string; ATestClassName: string);
begin

  if (ATestClassName <> '') and
     (
       (ACase='') OR
       (CurrentTestClass<>ATestClassName)
     ) then NewTestSet(ATestClassName);

   if ACase <> '' then
    CurrentTestCase := ACase;

end;

initialization
  system.ReportMemoryLeaksOnShutdown := True;

end.
