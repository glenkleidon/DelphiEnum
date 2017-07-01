unit MiniTestFramework;

interface

uses System.SysUtils,
  System.Generics.collections,
  System.rtti;

Const
  PASS_FAIL: array[0..1] of string = ('PASS', 'FAIL');
  FOREGROUND_DEFAULT=7;

var
  CurrentTestClass, CurrentTestCase: string;
  TotalPassedTestCases: integer =0;
  TotalFailedTestCases: integer =0;
  TotalErrors         : integer =0;
  TotalSets           : integer =0;

  SetPassedTestCases, SetFailedTestCases, SetErrors: integer;

Procedure TestSummary;
Procedure NewTestSet(AClassName: string);
Procedure SetTestCase(ACase: string; ATestClassName: string = '');
Function  CheckIsTrue(AResult: boolean; AMessage: string = ''): boolean;
Function  CheckIsEqual(AExpected, AResult: TValue;
  AMessage: string = ''): boolean;
Procedure Title(AText: string);
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

function SetHasErrors: boolean;
begin
  result := SetFailedTestCases+SetErrors<>0;
end;

function RunHasErrors: boolean;
begin
  result := SetHasErrors or (TotalFailedTestCases+TotalErrors<>0);
end;

Function ResultColour(AHasErrors: boolean):smallInt;
begin
  if AHasErrors then Result := clError else Result := clPass;
end;

procedure ClassResults;
begin

  if (SetPassedTestCases=0) and
     (SetFailedTestCases=0) and
     (SetErrors=0)
  then exit;

  Println(
     format(' Results> Passed:%-5d Failed:%-5d Errors:%-5d',[
              SetPassedTestCases,
              SetFailedTestCases,
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
    format('Total Sets:%-5d Passed:%-5d Failed:%-5d Errors:%-5d',[
              TotalSets-1, TotalPassedTestCases,
              TotalFailedTestCases, TotalErrors]
    ),
    ResultColour(RunHasErrors)
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
  SetErrors := 0;
  SameTestCounter := 0;
  LastTestCase := '';
  CurrentTestClass:=AClassName;

end;

Function CheckIsEqual(AExpected, AResult: TValue;
  AMessage: string = ''): boolean;
var
  lMessage,lCounter: string;
  lResult: integer;
begin
  Result := false;
  lResult := 0;
  try
    try
      lMessage := '';
      if AExpected.ToString <> AResult.ToString then
      begin
        lResult := 1;
        inc(SetFailedTestCases);
        if AMessage = '' then
          lMessage := format('%s   Expected: %s%s   Actual  :%s',
            [#13#10, AExpected.ToString, #13#10, AResult.ToString]);
      end;
      inc(SetPassedTestCases);
    except
      on e: exception do
      begin
        lResult := 1;
        lMessage := e.Message;
        inc(SetErrors);
      end;
    end;
  finally
    if LastTestCase=CurrentTestCase then inc(SameTestCounter) else SameTestCounter:=1;
    LastTestCase := CurrentTestCase;
    if SameTestCounter=1 then lCounter := '' else lCounter := '-'+SameTestCounter.ToString;
    Print(format('  %s-%s%s', [PASS_FAIL[lResult],CurrentTestCase,lCounter]));
    Println(lMessage,clMessage);
  end;
end;

Function CheckIsTrue(AResult: boolean; AMessage: string): boolean;
begin
  Result := CheckIsEqual(True, AResult);
end;

procedure SetTestCase(ACase: string; ATestClassName: string);
begin
  if ACase <> '' then
    CurrentTestCase := ACase;

  if (ATestClassName <> '') and
     (
       (ACase='') OR
       (CurrentTestClass<>ATestClassName)
     ) then NewTestSet(ATestClassName);

end;

initialization
  system.ReportMemoryLeaksOnShutdown := True;

end.
