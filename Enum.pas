unit Enum;

interface

uses System.SysUtils, System.TypInfo, System.Rtti;

const ENUM_CONTEXT_DEFAULT = 'EnumContextDefault';

Type

  TLabelAliases = TArray<string>;
  PLabelAliases = ^TLabelAliases;

  TLabelledEnum<T> = Record
  private
    fContext: string;
    fLabels : PLabelAliases;
    fTypeName: string;
    Procedure SetType;
    Function GetEnumTypeName: string;
    function GetTypeName: string;
    procedure setLabels(const Value: TLabelAliases); deprecated;
    function  getLabels: TLabelAliases;
  public
    InternalTypeInfo: PTypeInfo;
    Enum: T;
    Procedure Clear;
    Procedure CheckType;
    Property TypeName: string read GetEnumTypeName;
    Function ValueName: string;
    Property Labels: TLabelAliases read getLabels write setLabels;
    Property Context : string read fContext write fContext;
    Class function AsString(AType: T): string; static;
    Class Procedure SetTypeLabels(ALabels: TArray<String>; AContext : string = ENUM_CONTEXT_DEFAULT); static;
    Class Function GetTypeLabels(AContext : string = ENUM_CONTEXT_DEFAULT): TArray<String>; static;
    Class Procedure ClearTypeLabels(AContext: string = ENUM_CONTEXT_DEFAULT); static;
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
    Context: String;
    InternalTypeInfo: PTypeInfo;
    AliasArray: TLabelAliases;
  End;
var LabelledEnumAliases :TArray<TLabelledEnumAliasEntry>;

Procedure RegisterEnumAlias(Const ATypeInfo:PTypeInfo; AAliases: TLabelAliases;
           AContext: String=ENUM_CONTEXT_DEFAULT);
Function GetEnumNameList(ATypeInfo: PTypeInfo; AStart: Integer=0;
        ACount: Integer = -1): TArray<String>;
Function GetEnumAliasList(ATypeInfo:PTypeInfo; Astart: Integer=0;
        ACount: Integer = -1; AContext: String = ENUM_CONTEXT_DEFAULT): TArray<String>;
procedure DeRegisterEnumAlias(ATypeInfo: PTypeINfo; AAll: boolean = false;
         AContext:string = ENUM_CONTEXT_DEFAULT);

implementation
  uses AnsiStrings;

Procedure RegisterEnumAlias(Const ATypeInfo:PTypeInfo; AAliases: TLabelAliases;
    AContext: string=ENUM_CONTEXT_DEFAULT);
var
   lLabelEntry:TLabelledEnumAliasEntry;
   lTargetName: string;
   lFirstEmpty, l, i : integer;
begin
   //note: If you want to change labels for context,
   // you need to remove it first.
   // Trying to add context that is already set will be ignored.

   if (ATypeInfo=nil) or (AAliases=nil) then exit;

   lTargetName := string(AtypeInfo.Name);
   lFirstEmpty := -1;
   // Check For Duplicate and Empty Slots to re-use
   l := length(LabelledEnumAliases);
   for I := 0 to l-1 do
   begin
     lLabelEntry := LabelledEnumAliases[i];
     if lLabelEntry.InternalTypeInfo=nil then
     begin
       if lFirstEmpty=-1 then lFirstEmpty := i;
       continue;
     end;
     if SameText(lTargetName, string(lLabelEntry.InternalTypeInfo.Name)) and
        SameText(AContext, lLabelEntry.Context) then exit;
   end;

   if lFirstEmpty<>-1 then
     l := lFirstEmpty
   else
     setlength(LabelledEnumAliases,l+1);
   // we Probably dont need to duplicate here as it dynamic
   // arrays are reference counted.  REMOVE LATER???
   LabelledEnumAliases[l].InternalTypeInfo := ATypeInfo;
   LabelledEnumALiases[l].Context := AContext;
   setlength(LabelledEnumAliases[l].AliasArray,length(AAliases));
   for i := Low(AAliases) to High(AAliases) do
     LabelledEnumAliases[l].AliasArray[i] := AAliases[i];

   System.TypInfo.AddEnumElementAliases(ATypeInfo, LabelledEnumAliases[l].AliasArray);

end;

procedure DeRegisterEnumAlias(ATypeInfo: PTypeINfo; AAll: boolean = false;
         AContext:string = ENUM_CONTEXT_DEFAULT);
var
   lTargetName: string;
   i,l: integer;
begin
  //not thread safe as yet.
   if (ATypeInfo=nil) then exit;

   lTargetName := string(AtypeInfo.Name);
   l := length(LabelledEnumAliases);

   for I := 0 to l-1 do
   begin
     if (SameText(lTargetName, string(LabelledEnumAliases[i].InternalTypeInfo.Name))) and
        ( (AAll) or (SameText(AContext, LabelledEnumAliases[i].Context))) then
     begin
       setlength(LabelledEnumAliases[i].AliasArray,0);
       LabelledEnumAliases[i].Context := '';
       LabelledEnumAliases[i].InternalTypeInfo := nil;
       break;
     end;
   end;

   // Remove references in the Type
   RemoveEnumElementAliases(ATypeInfo);
   if AAll then exit;

   // Add Back any we still need
   l := length(LabelledEnumAliases);
   for i := 0 to l-1 do
   begin
     if LabelledEnumAliases[i].Context='' then continue;
     if (LabelledEnumAliases[i].InternalTypeInfo<>Nil) and
       (SameText(lTargetName, string(LabelledEnumAliases[i].InternalTypeInfo.Name))) then
       System.TypInfo.AddEnumElementAliases(
          ATypeInfo, LabelledEnumAliases[i].AliasArray );
   end;
end;

Function GetEnumAliasList(ATypeInfo:PTypeInfo; Astart: Integer=0;
        ACount: Integer = -1; AContext: string = ENUM_CONTEXT_DEFAULT): TLabelAliases;
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
     if (AtypeInfo=lLabelEntry.InternalTypeInfo) and
        (AContext=lLabelEntry.Context) and
        (AtypeInfo.Name = lLabelEntry.InternalTypeInfo.Name) then
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


Function GetEnumNameList(ATypeInfo: PTypeInfo; AStart: Integer=0;
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

  lAliases := GetEnumAliasList(AType.InternalTypeInfo,v,1,AType.Context);
  if length(lAliases)>=1 then
  begin
    Result := lAliases[0];
    if Result.Length>0 then exit;
  end;
  Result := getEnumName(AType.InternalTypeInfo, v);
end;

class operator TLabelledEnum<T>.Implicit(AType: TLabelledEnum<T>): T;
begin
  Result := AType.Enum;
end;

class operator TLabelledEnum<T>.Implicit(ALabel: String): TLabelledEnum<T>;
begin
  // uses implicit cast to set the integer value;
  Result.CheckType;
  Result := GetEnumValue(Result.InternalTypeInfo, ALabel);
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

class function TLabelledEnum<T>.AsString(AType: T): string;
var lType: TLabelledEnum<T>;
begin
 lType := Atype;
 result := lType;
end;

procedure TLabelledEnum<T>.CheckType;
begin
  if fTypeName.Length = 0 then SetType;
end;

procedure TLabelledEnum<T>.Clear;
begin
  self.fContext := ENUM_CONTEXT_DEFAULT;
  self.fTypeName := '';
  self.GetTypeName;
end;

class procedure TLabelledEnum<T>.ClearTypeLabels(AContext: string);
begin
  DeRegisterEnumAlias(TypeInfo(T),false,AContext);
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
  result := string(Self.InternalTypeInfo.Name);
end;

function TLabelledEnum<T>.getLabels: TLabelAliases;
begin
  CheckType;
  Result:= GetEnumAliasList(InternalTypeInfo,0,-1,FContext);
end;

class function TLabelledEnum<T>.GetTypeLabels(AContext: string): TArray<String>;
begin
  Setlength(Result,0);
  result := GetEnumAliasList(TypeInfo(T),0,-1,AContext);
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
//  if Not (self.fLabels = nil) then RemoveEnumElementAliases(InternalTypeInfo);
//  System.TypInfo.AddEnumElementAliases(InternalTypeInfo, Value);
  // again because we cant directly access the system.typeinfo's copy of the
  // EnumALiases array, we will need to keep a copy
  RegisterEnumAlias(InternalTypeInfo,Value,fContext);
end;

procedure TLabelledEnum<T>.SetType;
begin
  Self.fLabels := nil;
  self.InternalTypeInfo := Typeinfo(T);
  fTypeName := System.TypInfo.GetTypeName(InternalTypeInfo);
  if Self.fContext='' then self.fContext := ENUM_CONTEXT_DEFAULT;
  
end;

class procedure TLabelledEnum<T>.SetTypeLabels(ALabels: TArray<String>;
  AContext: string);
begin
  RegisterEnumAlias(TypeInfo(T), ALabels, AContext);
end;

function TLabelledEnum<T>.ValueName: string;
var v: integer;
begin
  CheckType;
  v := Self;
  Result := getEnumName(InternalTypeInfo,v );
end;

end.
