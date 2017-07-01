unit StaticSelfDescribe;

interface
 uses System.sysUtils;


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

implementation

 { TSomeTypeLabels<TSomeType> }
class operator TLabelledSomeType.Implicit(AType: TSomeType): TLabelledSomeType;
begin
  Result.Enum := AType;
end;

class operator TLabelledSomeType.Implicit(AType: TLabelledSomeType):string;
 var lType : TSomeType;
begin
   lType := AType;
   Result:=TsomeTypeAsString[lType];
end;

class operator TLabelledSomeType.Implicit(AType: TLabelledSomeType):TSomeType;
begin
  Result := AType.Enum;
end;

class operator TLabelledSomeType.Implicit(ALabel: String):TLabelledSomeType;
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

class operator TLabelledSomeType.Implicit(AType: Integer):TLabelledSomeType;
begin
  result.Enum := TSomeType(Atype);
end;

class operator TLabelledSomeType.Implicit(AType: TLabelledSomeType):Integer;
begin
  result := ord(AType.Enum);
end;


end.
