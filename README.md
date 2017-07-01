# DelphiEnum
_**Generic Record Type Helper allowing Implicit bi-directional String and Integer Casting of Enumerated Types**_

Ever wanted to automatically display a sensible Label for an Enumerated Type to the User?  How can you easily and efficient 
cast from a string value to an Internal Enumerated type?  

For example how do you deal with a value posted from a web page or JSON stream which is an element of drop down list? How do you 
identify the corresponding Identifier in your Enumerated Type?  How do you populate that drop down list with labels 
(in the users target Language) when you are building the HTML in the first place? 

Would you like to be able to populate a dataset with Labels, String Ids or Integer ids and read them back again directly 
into your Enumerated Type with no extra code?

The _*TLabelledEnum*_ provides this functionality implicitly and can be used with your existing Enumerated types (_explicitly 
assigned ordinality is not fully supported_).  

## Using the _*TLabelledEnum*_ Enumerated Type

The simplest way to get started is to:
  1. Add the Enum.Pas to your application;
  2. Declare your own type (eg TMyType = (OptionA,OptionB,OptionC);
  3. [Optionally] Declare a generic TLabelledEnum _of_ your type as a convenient, 
  descriptive Alias (eg TMyLabelledType=TLabelledEnum\<TMyType\>) 
  4. [Optionally] declare a set of labels 
 
You can then implicitly cast to and from strings, integers or the original type: but you will 
need to be careful of type safety as **casting an invalid value will be _ignored_ - exceptions
will not be thrown**! 

When no labels are defined, casting to and from string is by the (case insensitive) Identifier name eg:
```MyLabelledType='optiona';```

Casting TO and FROM Integers and the original Enumerated type are also allowed 
eg ```MyLabelledType:=OptionA;```
and ```MyLabelledType:=0;``` both work As does ```x:=MyLabelledType+2;``` and ```lMyType:=MyLabelledType;``` 

When labels are defined, casting TO a string shows the label eg ```writeln('Label is "'+MyLabelledType+'"');``` will 
output *Label is "Option A"*, and casting FROM as string either the _Label_ or the _Type Identifier_ is allowed eg 
```MyLabelledType='Option A';``` or ```MyLabelledType='OptionA';```  


The Demo program in this repo is called _SelfDescribing.exe_ shows the basic features. 


### Demo Program
```
DEMO - Using the Generic Enum.TLabelledEnum Type
================================================
The Record Type "TLabelledEnum" is a thread safe, leakproof Generic Record Type
implemented as a Helper for enumerated types.
It allows implict type casting to and from static type names, string and integers.
Allows Code such as:

----------------------------------------------------------------------------------

     Uses  Enum;
     const TMyLabels : TArray<String> = ['Option A', 'Option B', 'Option C'];
     type  TMyType  = (MyOptionA, MyOptionB, MyOptionC)
           TLabelledMyType = TLabelledEnum<TMyType>;
     var   OptionEnum = TLabelledMyType;
     Begin
       OptionEnum.Labels:=TMyLabels;
       OptionEnum:=MyOptionA;
       ThisType:=OptionEnum;
       if (OptionEnum = 'option a') then OptionEnum := ThisType+1;
       Writeln('OptionEnum is "'+OptionEnum+'"'); // Shows: OptionEnum is "Option B"
     End.

-----------------------------------------------------------------------------------

Execute above Example:
OptionEnum is "Option B"
```

## Origins
This project started as as a moment of reflection - I very often want to be able to Display a label for an
enumerated type.  This is very common and lots of techniques work.

I discovered that it was possible to create a Record Helper for an enumerated type which allow 
casting of the enum type to a string eg 
```
type
   TSomeType = (MyOptionA, MyOptionB, MyOptionC);

   TSomeTypeHelper = Record helper for TSomeType
     Class Function AsString(AType: TSomeType): string; static;
   End;

   class function TSomeTypeHelper.AsString(AType: TSomeType): string;
   begin
     case Atype of
       MyOptionA: result := 'Option A';
       MyOptionB: result := 'Option B';
       MyOptionC: result := 'Option C';
     end;
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
However this did not go quite far enough.  I want to cast in both directions and have a Label display,
not just the internal name of the element;

##ADUG Mailing Group Responses
I posted this little tit-bit on the ADUG mailing group and I got encouraging and helpful replies from 
  + John McDonald
  + Bob Swart (Dr Bob)
  + Aaron Christiansen
  + Jared Davison
  
 The Email Trail is in the repo. Thanks to All.

This got me thinking even further and I decided that it would be possible to extend the concept to allow for 
implicit bi-directional conversions and I eventually came up with a static solution.  That got me thinking even
more.  A static solution means you have to write the code every time - and that would not save time, but 
would perhaps make things more consistent.  

Finally, I worked through the issues of making a generic type which would work with any existing enumerated type 
and thus this project was born.

##TO DO:
  + Enumerated types with explict ordinality
