# Delphi Enum Unit: _**TLabelledEnum**_
_**A Generic Record Type Wrapper for Enumerated types adding multi-language Text Label support, with implicit bi-directional String and Integer Casting**_

## Purpose
The primary purpose of _*TLabelledEnum*_ is to extend the **any existing** Enumerated type to support "context" specific text labels which can be cast implicitly back and forth between the enumerated type.  For example, the Variable MyOption being a type of _TMyOption=(OptionA, OptionB, OptionC)_ can be used can be used to populate a Tcombobox with labels and the Text of the can be used directly to set the value like this:

``` if (cbDropDownList.text=MyOption) then ...``` 

And

``` cbDropDownlist.items.text := MyOption.labels; ```

Setting the default for the combo is simply

``` cbDropDownlist.text := MyOption; ```


## Text Label Support

*_TLabelledNum_* supports adding any number of text labels to a paticular ordinal Value so that the text displayed is more user friendly and/or context specific.  Ie OptionA can be displayed as "Option A" or perhaps "Opcion A" if the user's default language is Spanish. Assigning either (case insensitive) "Option A" or "Opcion A" to a labelled enum type will result in the ordinal value of _OptionA_.

```  MyOption := 'option a'; ```

## Integer Value support

Integer values of Enumerated Types are also supported so the following are also valid
``` MyOption := 1; ``` and ``` x := MyOption+1;```

## A Generic Type with Class methods 

The **TLabelledEnum** is a generic record type that can wrap **any** existing Enumerated type to  provide Text label support. 
An example use case is creating a user interface to allow a user to specify a connection string for a Database.  Wrapping _ADODB.TConnectMode_ in-line like this ``` TLabelledEnum<TConnectMode>.getTypeLabels``` returns a string array of the default labels which you can use to populate a drop down list. Once the user has made the selection, you can simply use the text result to cast back to the type

```ADOConnection.ConnectionMode := TLabelledEnum<TConnectMode>(cbConnectDropDown.text);```

To make things a little less busy, declare an alias
```type TConnectionMode = TLabelledEnum<TConnectMode>;```
and the above line becomes 
```ADOConnectionType := TConnectionMode(cbConnectDropDown.text);```


## Demo Program
The Enum repository includes a program to demonstrate the basic functions.  More advanced features such as multiple Context support are not shown.

```
DEMO - Using the Generic Enum.TLabelledEnum Type
===================================================================================
The Record Type "TLabelledEnum" is a Generic Record Type that adds Label support to 
existing Enumerated types.
By creating a Type of "TLabelledEnum<TYourType>" it is very simple to add one or 
more labels to each TYourType Option and then use the Text label, integer value or 
named identifier interchangably in your code. Eg:

-----------------------------------------------------------------------------------
     Uses  Enum;
     const TMyLabels : TArray<String> = ['Option A', 'Option B', 'Option C'];
     type  TMyType  = (MyOptionA, MyOptionB, MyOptionC)
           TLabelledMyType = TLabelledEnum<TMyType>;
     var   OptionEnum = TLabelledMyType;
           ThisType: integer;
     Begin
       TLabelledMyType.SetTypeLabels(TMyLabels); //<=Add labels to your type
       OptionEnum:=MyOptionA;                    //<=Assign the value as normal
       ThisType:=OptionEnum;                     //<=OR Assign to integers
       if (OptionEnum = 'option a') then         //<=OR Use labels instead
              OptionEnum := ThisType+1;          //<=AND Assign from integers
       Writeln('OptionEnum is "' +               //<=And use it as a string
              +OptionEnum+'"');                  // Shows: OptionEnum is "Option B"
     End.
-----------------------------------------------------------------------------------
Execute above Example:
OptionEnum is "Option B"
```

## Supporting Multiple _Contexts_ 

The type supports multiple labels for the same type which can help to provide internationalisation and alternate formatting.

You can provide a set of labels for specific contexts.  Eg "Under certian conditions, I want the Enumerated type to have a different label." The simplest example of this is support for multiple languages.  Eg _if browser Language Code is EN the set the context to English._

If a user speaks french, but you need to log activity in English, the same variable can be used to log the selection in english and output to the user in french (assuming you have defined a set of labels in french).

Perhaps a more powerful example is where an interface from one system has a value for Gender of "Female" and but another system expects the field to have a value of "F" then _TLabelledEnum_ can be set by either label to the same ordinal value of _genFemale_.  Likewise, the correct field text can be output automatically for either interface by selecting the appropriate context.

## Class functions and Properties
  + ```Enum : T``` 
    + A Public variable holding of the base type (direct access to the underlying base type)
  + ```Property Context : string read fContext write fContext;```
    + Sets or gets the current Variable context.  The string can be of any value, and should uniquely idenifity the context for the labels. The default context is ```'EnumContextDefault'```

  + ```Class function AsString(AType: T): string; static;```
    + Returns the label for the (base) enumerated type identifier in the default context

  + ```Class Procedure SetTypeLabels(ALabels: TArray<String>; AContext : string = ENUM_CONTEXT_DEFAULT); static;```
    + Sets the Type labels for the specified context

  + ```Class Function GetTypeLabels(AContext : string = ENUM_CONTEXT_DEFAULT): TArray<String>; static;```
    + Returns a string array of the labels in the default context

  + ```Class Procedure ClearTypeLabels(AContext: string = ENUM_CONTEXT_DEFAULT); static;```
    + Clears the type labels for the specfic context
 

## Using the _*TLabelledEnum*_ Enumerated Type

The simplest way to get started is to:
  1. Add the Enum.Pas to your application;
  2. Declare your own type or use and existing system one (eg TMyType = (OptionA,OptionB,OptionC);
  3. [Optionally] Declare a generic TLabelledEnum _of_ your type as a convenient, descriptive Alias (eg TMyLabelledType=TLabelledEnum\<TMyType\>) 
  4. [Optionally] declare one or more sets of labels as dynamic arrays
  5. Use the Class function  

**_NOTE:_ 1** Labels _always_ have Global Scope whether the class function is used or from an instance of the type.  ie ```TMyLabelledXYZType.SetTypeLabels(MyXYZLabels)``` has the same effect as ```var MyLabelledXYZ: TMyLabelledXYZType; Begin MyLabelledXYZ.SetTypeLabels(MyXYZLabels);...```  You only need to specify the type labels ONCE for the application.  Using the Initialization section is suggested. 
 
**_NOTE:_ 2** Casting an invalid value will be _ignored_ - **exceptions will not be thrown**!
**_NOTE:_ 3** Because the compiler is confused by the implicit casting, when using a CASE statment, use the ```Enum``` public variable eg:

```
  Case MyLabelledType.Enum of
    OptionA:;
    OptionB:;
    OptionC:;
  end;
```  

When no labels are defined, casting to and from string is by the (case insensitive) Identifier name eg:

```
MyLabelledType:='optiona';
```

Casting TO and FROM Integers and the original Enumerated type are implicit (no brackets required) eg
```
MyLabelledType:=OptionA;
MyLabelledType:=0;
lMyType:=MyLabelledType;  //cast to "base" type
``` 

When labels are defined, casting TO a string shows the label:
eg

 ```writeln('Label is "'+MyLabelledType+'"');``` 

will output the label eg ```Label is Option A```, and casting FROM a string either the _Label_ or the _Type Identifier_ is allowed eg 
```if (MyLabelledType='Label is Option A') then``` or ```MyLabelledType:='OptionA';```  


## Origins of the _TLablledEnum_ Type
This project started as as a moment of reflection - I very often want to be able to Display a label for an enumerated type.  This is very common and lots of techniques work.

I discovered that it was possible to create a Record Helper for an enumerated type which allows casting of the enum type to a string and with some help we eventually came up with this solution: 
```
type
   TSomeType = (MyOptionA, MyOptionB, MyOptionC);
   TSomeTypeAsString: array[TSomeType] of string =
       ('Option A', 'Option B', 'Option C');

   TSomeTypeHelper = Record helper for TSomeType
     Class Function AsString(AType: TSomeType): string; static;
   End;

   class function TSomeTypeHelper.AsString(AType: TSomeType): string;
   begin
     Result := TSomeTypeAsString[Self]
   end;
 

```
This allows you to cast to a string from the eg
```
 write(format(
            'Sometype A is "%s"'#13#10 +
            'Sometype B is "%s"'#13#10 +
            'Sometype C is "%s"'#13#10,
           [ TSomeType.MyOptionA.AsString,
             TSomeType.MyOptionB.AsString,
             TSomeType.MyOptionC.AsString ]
     ));
```

However this did not go quite far enough.  I want to cast in both directions and have a Label display, not just the internal name of the element;

##ADUG Mailing Group Responses
I posted this little tid-bit on the ADUG mailing group and I got encouraging and helpful replies from 
  + John McDonald
  + Bob Swart (Dr Bob)
  + Aaron Christiansen
  + Jared Davison
  + Grahame Grieve
  
 The Email Trail is in the repo. Thanks to All who contributed.

The conversation got me thinking even further and I decided that it would be possible to extend the concept to allow for implicit bi-directional conversions and I eventually came up with a static solution.  However, a static solution means you have to re-write the code and reimplement for every type.  That may be a reasonable approach in some cases especially with regard to containing the scope.  In the end though, it wont save any time and it will bloat your code.

It seemed that it should be possible to write a generic solution to overcome the need to re-write.  I worked through the issues and finally come up with a solution that work with any existing enumerated type and thus this project was born.

## TO DO:
  + Enumerated types with explict ordinality
