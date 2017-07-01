unit Enum;

interface

uses System.SysUtils, System.TypInfo, System.Rtti;

Type

  TLabelAliases = TArray<string>;
  PLabelAliases = ^TLabelAliases;

  TLabelledEnum<T> = Record
  private
    fLabels : PLabelAliases;
    fTypeName: string;
    Procedure SetType;
    Function GetEnumTypeName: string;
    function GetTypeName: string;
    procedure setLabels(const Value: TLabelAliases);
    function getLabels: TLabelAliases;
  public
    EnumTypeInfo: PTypeInfo;
    Enum: T;
    Procedure Clear;
    Procedure CheckType;
    Property TypeName: string read GetEnumTypeName;
    Function ValueName: string;
    Property Labels: TLabelAliases read getLabels write setLabels;
    Class Operator Implicit(AType: TLabelledEnum<T>): string;
    Class operator Implicit(ALabel: String): TLabelledEnum<T>;
    Class operator Implicit(AType: T): TLabelledEnum<T>;
    Class operator Implicit(AType: TLabelledEnum<T>): T;
    Class operator Implicit(ATypeIndex: Integer): TLabelledEnum<T>;
    Class operator Implicit(AType: TLabelledEnum<T>): Integer;
    Class operator Equal(AType: TLabelledEnum<T>; AText: String):boolean;
    Class operator Equal(AType: TLabelledEnum<T>; AIndex:Integer):boolean;
    Class operator NotEqual(AType: TLabelledEnum<T>; AText: String):boolean;
    Class operator NotEqual(AType: TLabelledEnum<T>; AIndex:Integer):boolean;
  End;

// The System.TypInfo has a property "EnumAliases" which we COULD use Directly
// if it was not Internally Scoped OR we had an equivalent call to
// GetAliasEnumValue called "GetAliasEnumName(TypeInfo: PTypeInfo; const Integer): string
// But, because it doesn't we have to keep our own Factory implementation here.
  TLabelledEnumAliasEntry = Record
    EnumTypeInfo: PTypeInfo;
    AliasArray: TLabelAliases;
  End;
var LabelledEnumAliases :TArray<TLabelledEnumAliasEntry>;

Procedure RegisterEnumAlias(Const ATypeInfo:PTypeInfo; AAliases: TLabelAliases);
Function GetEnumNameList(ATypeInfo: PTypeInfo; AStart: Integer;
        ACount: Integer = -1): TArray<String>;
Function GetEnumAliasList(ATypeInfo:PTypeInfo; Astart: Integer;
        ACount: Integer = -1): TArray<String>;


implementation
  uses AnsiStrings;

Procedure RegisterEnumAlias(Const ATypeInfo:PTypeInfo; AAliases: TLabelAliases);
var
   lLabelEntry:TLabelledEnumAliasEntry;
   lTargetName: string;
   l, i : integer;
begin
   if (ATypeInfo=nil) or (AAliases=nil) then exit;

   lTargetName := string(AtypeInfo.Name);

   // Check For Duplicate
   for lLabelEntry in LabelledEnumAliases do
     if SameText(lTargetName, string(lLabelEntry.EnumTypeInfo.Name)) then exit;
   l := length(LabelledEnumAliases);
   setlength(LabelledEnumAliases,l+1);
   LabelledEnumAliases[l].EnumTypeInfo := ATypeInfo;
   setlength(LabelledEnumAliases[l].AliasArray,length(AAliases));
   for i := Low(AAliases) to High(AAliases) do
     LabelledEnumAliases[l].AliasArray[i] := AAliases[i];
end;


Function GetEnumAliasList(ATypeInfo:PTypeInfo; Astart: Integer;
        ACount: Integer = -1): TLabelAliases;
var
   lLabelEntry:TLabelledEnumAliasEntry;
   i,p,lEnd: Integer;
begin
  if (ACount=-1) or ((ACount+AStart-1)>ATypeInfo.TypeData.MaxValue) then
      lEnd := ATypeInfo.TypeData.MaxValue
  else lEnd :=(AStart+ACount-1);

   for lLabelEntry in LabelledEnumAliases do
   begin
     // The Type Label should never really shift, so we COULD PROBABLY
     // just use the Pointer directly eg
     // if AtypeInfo=lLabelEntry.TypeInfo, but just in case, we'll check
     // the Type Name
     if (AtypeInfo=lLabelEntry.EnumTypeInfo) and (AtypeInfo.Name = lLabelEntry.EnumTypeInfo.Name) then
     begin
       setlength(Result,(lEnd-AStart+1));
       p := -1;
       for i := AStart to lEnd do
       begin
         inc(p);
         result[p] := lLabelEntry.AliasArray[i];
       end;
       exit;
     end;
   end;
end;


Function GetEnumNameList(ATypeInfo: PTypeInfo; AStart: Integer;
        ACount: Integer = -1): TArray<String>;
var lEnd,i: integer;
    P : pointer; // pointing to the array of namelist
    SP,DP : pAnsiChar; // pointers to the source and destination strings;
    S : shortString; // Temporary string
    strLength: integer;

  function MovePointer(const m: pByte; size: integer): Pointer;
  begin
    Result := m + size;
  end;
begin
  if (ACount=-1) or ((ACount+AStart-1)>ATypeInfo.TypeData.MaxValue) then
      lEnd := ATypeInfo.TypeData.MaxValue
  else lEnd :=(AStart+ACount-1);
  P := @(ATypeInfo.TypeData.NameList);
  setlength(Result,(lEnd-AStart+1));
  for i := AStart to lEnd do
  begin
    StrLength := integer(pbyte(P)^);
    setlength(s,StrLength);
    DP := @S[1];
    SP := MovePointer(P,1);
    AnsiStrings.StrLCopy(DP,SP,StrLength);
    Result[i] := string(s);
    P := MovePointer(P,1+strLength);
  end;

end;

function HashTypeInfo(TypeInfo: PTypeInfo): Byte;
var
  I: Integer;
  Value: NativeUInt;
begin
  Result := $B5;
  Value := NativeUInt(TypeInfo);
  for I := 0 to SizeOf(TypeInfo) - 1 do
    Result := Result xor ((Value shr (I * SizeOf(Byte))) and $FF);
end;

{ TLabels<T> }
class operator TLabelledEnum<T>.Implicit(AType: T): TLabelledEnum<T>;
begin
  Result.Enum := AType;
end;

class operator TLabelledEnum<T>.Implicit(AType: TLabelledEnum<T>): string;
var v: integer;
    lAliases : TArray<String>;
begin
  Result := '';
  AType.checkType;
  v := AType;

  lAliases := GetEnumAliasList(AType.EnumTypeInfo,v,1);
  if length(lAliases)>=1 then
  begin
    Result := lAliases[0];
    if Result.Length>0 then exit;
  end;
  Result := getEnumName(AType.EnumTypeInfo, v);
end;

class operator TLabelledEnum<T>.Implicit(AType: TLabelledEnum<T>): T;
begin
  Result := AType.Enum;
end;

class operator TLabelledEnum<T>.Implicit(ALabel: String): TLabelledEnum<T>;
begin
  // uses implicit cast to set the integer value;
  Result.CheckType;
  Result := GetEnumValue(Result.EnumTypeInfo, ALabel);
end;

class operator TLabelledEnum<T>.Implicit(ATypeIndex: Integer): TLabelledEnum<T>;
var
  v1 : PByte;
  v2 : PWord;
  i : Integer;
begin
  Result.CheckType;  // Assertion in GetEnumName protects against wrong data type
  if SizeOf(Result.Enum)=1 then
  begin
    v1 := @Result.Enum;
    v1^ := ATypeIndex AND $FF;
  end else
  begin
    v2 := @Result.Enum;
    v2^ := ATypeINdex AND $FFFF;
  end;
end;

procedure TLabelledEnum<T>.CheckType;
begin
  if fTypeName.Length = 0 then SetType;
end;

procedure TLabelledEnum<T>.Clear;
begin
  self.fTypeName := '';
  self.GetTypeName;
end;

class operator TLabelledEnum<T>.Equal(AType: TLabelledEnum<T>;
  AIndex: Integer): boolean;
  var v: integer;
begin
  v := Atype;
  Result := Aindex=v;
end;

class operator TLabelledEnum<T>.Equal(AType: TLabelledEnum<T>;
  AText: String): boolean;
begin
  result := SameText(AText, Atype)
end;

function TLabelledEnum<T>.GetEnumTypeName: string;
begin
  result := string(Self.EnumTypeInfo.Name);
end;

function TLabelledEnum<T>.getLabels: TLabelAliases;
begin
  CheckType;
  Result:= GetEnumAliasList(EnumTypeInfo,0);
end;

function TLabelledEnum<T>.GetTypeName: string;
begin
  CheckType;
  Result := fTypeName;
end;

class operator TLabelledEnum<T>.Implicit(AType: TLabelledEnum<T>): Integer;
var
  v1 : PByte;
  v2 : PWord;
  i : Integer;
begin
  AType.CheckType;
  if SizeOf(AType.Enum)=1 then
  begin
    v1 := @AType.Enum;
    Result:= v1^
  end else
  begin
    v2 := @AType.Enum;
    Result := v2^;
  end;
end;

class operator TLabelledEnum<T>.NotEqual(AType: TLabelledEnum<T>;
  AText: String): boolean;
begin
  Result := NOT(Atype=Atext);
end;

class operator TLabelledEnum<T>.NotEqual(AType: TLabelledEnum<T>;
  AIndex: Integer): boolean;
begin
  Result := NOT(Atype=Aindex);
end;

procedure TLabelledEnum<T>.setLabels(const Value: TLabelAliases);
begin
  CheckType;
  if Not (self.fLabels = nil) then RemoveEnumElementAliases(EnumTypeInfo);
  System.TypInfo.AddEnumElementAliases(EnumTypeInfo, Value);
  // again because we cant directly access the system.typeinfo's copy of the
  // EnumALiases array, we will need to keep a copy
  RegisterEnumAlias(EnumTypeInfo,Value);
end;

procedure TLabelledEnum<T>.SetType;
begin
  Self.fLabels := nil;
  self.EnumTypeInfo := Typeinfo(T);
  fTypeName := System.TypInfo.GetTypeName(EnumTypeInfo);
end;

function TLabelledEnum<T>.ValueName: string;
var v: integer;
begin
  CheckType;
  v := Self;
  Result := getEnumName(EnumTypeInfo,v );
end;

end.
