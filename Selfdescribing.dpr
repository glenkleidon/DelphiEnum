program Selfdescribing;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

// Generic Type (Can be reused for any ENUM

  Type

   TSomeType = (MyOptionA, MyOptionB, MyOptionC);

  Const
   TSomeTypeAsString: array[TSomeType] of string =
       ('Option A', 'Option B', 'Option C');

   Type

   TLabelledSomeType = Record
      Enum:TSomeType;
      Class Operator Implicit(AType: TLabelledSomeType): string;
      Class operator Implicit(ALabel: String): TLabelledSomeType;
      Class operator Implicit(AType: TSomeType): TLabelledSomeType;
      Class operator Implicit(AType: TLabelledSomeType): TSomeType;
      Class operator Implicit(AType: Integer): TLabelledSomeType;
      Class operator Implicit(AType: TLabelledSomeType): Integer;
   End;

 { TSomeTypeLabels<TSomeType> }
  class operator TLabelledSomeType.Implicit(AType: TSomeType):
TLabelledSomeType;
  begin
    Result.Enum := AType;
  end;

  class operator TLabelledSomeType.Implicit(AType: TLabelledSomeType):
string;
  var lType : TSomeType;
  begin
     lType := AType;
     Result:=TsomeTypeAsString[lType];
  end;

  class operator TLabelledSomeType.Implicit(AType: TLabelledSomeType):
TSomeType;
  begin
    Result := AType.Enum;
  end;

  class operator TLabelledSomeType.Implicit(ALabel: String):
TLabelledSomeType;
  var i: integer;
      lLabel: string;
  begin
   // should be nicer than this...
     result.Enum := MyOptionA;
     i:=-1;
     for lLabel in TSomeTypeAsString do
     begin
      inc(i);
      if SameText(ALabel,lLabel) then
      begin
        result.Enum := TSomeType(i);
        exit;
      end;
     end;
  end;

  class operator TLabelledSomeType.Implicit(AType: Integer):
TLabelledSomeType;
  begin
     result.Enum := TSomeType(Atype);
  end;

  class operator TLabelledSomeType.Implicit(AType: TLabelledSomeType):
Integer;
  begin
    result := ord(AType.Enum);
  end;

var Stype: TSomeType;
    SLType: TLabelledSomeType;
    k:integer;

begin
  try
   // You can now use SLType instead of STYPE

   SLType := 'Option C';
   Stype :=SLType;
   if Stype=MyOptionC then
     Writeln(format('Ord value of Stype is %d',[ord(Stype)]));

   if SLType.Enum in [MyOptionA,MyOptionA] then writeln('Something went wrong')
     else writeln('Yep, Stype is '+SLType);

   SLType :='option a';
   Writeln('Changed to '+slType);

   SLType := MyOptionB;
   Writeln('Changed to '+slType);

   SLType := 2;
   Writeln('Changed to '+slType);

   readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
