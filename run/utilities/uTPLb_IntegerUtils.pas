unit uTPLb_IntegerUtils;
interface


{$IF CompilerVersion < 21.00}  // Meaning "before Delphi 2010".
type
  uint32 = cardinal; // Must be unsigned 32 bit 2's complement integer
                     //  with native operational support.
  uint16 = word;
{$ifend}

// NOTE: In Delphi 2010, uint32 is a standard type defined in the system unit.



function Add_uint64_WithCarry( x, y: uint64; var Carry: Boolean): uint64;
function Add_uint32_WithCarry( x, y: uint32; var Carry: Boolean): uint32;

function Subtract_uint64_WithBorrow( x, y: uint64; var Borrow: Boolean): uint64;
function Subtract_uint32_WithBorrow( x, y: uint32; var Borrow: Boolean): uint32;

function BitCount_8 ( Value: byte): integer;
function BitCount_16( Value: uint16): integer;
function BitCount_32( Value: uint32): integer;
function BitCount_64( Value: uint64): integer;
function CountSetBits_64( Value: uint64): integer;

// About fundamental integer types in TurboPower LockBox 3+

// Identifier    Bits              Signage    Requires          is Native
//                                           compile-time
//                                           operational
//                                           support?
// ==================================================================================
// byte            8              unsigned     True               False
// uint16         16              unsigned     True               False
// uint32         32              unsigned     True             don't care
// uint64         64              unsigned     True             don't care
// int64          64                signed     True             don't care
// integer       don't care         signed     True               True
// cardinal      don't care       unsigned     True               True

implementation





uses SysUtils;



function Add_uint32_WithCarry( x, y: uint32; var Carry: Boolean): uint32;
// The following code was inspired by
// http://www.delphi3000.com/articles/article_3772.asp?SK=
//  from Ernesto De Spirito.
asm
// The following 3 lines sets the carry flag (CF) if Carry is True.
// Otherwise the CF is cleared.
// The third parameter is in ecx .
test byte ptr [ecx], $01   // True == $01
jz @@t1
stc
@@t1:
adc eax, edx              // result := x + y + Carry
setc byte ptr [ecx]       // Puts CF back into Carry
end;

function Subtract_uint32_WithBorrow( x, y: uint32; var Borrow: Boolean): uint32;
asm
// The third parameter is in ecx .
test byte ptr [ecx], $01
jz @@t1
stc                       // CF = Ord( Borrow)
@@t1:
sbb eax, edx              // result := x - y + (CF * 2^32)
setc byte ptr [ecx]       // Borrow := CF = 1
end;



function Add_uint64_WithCarry( x, y: uint64; var Carry: Boolean): uint64;
asm
// The third parameter is in eax . Contrast with the 32 bit version of this function.
mov ecx,eax
test byte ptr [ecx], $01 // CF := 0; ZF := not Carry;
jz @@t1                  // if not ZF then
stc                      //   CF := 1;
@@t1:
mov eax,[ebp+$10]   // eax := x.l;
mov edx,[ebp+$14]   // edx := x.h;
adc eax,[ebp+$08]   // eax := eax + y.l + CF; CF = new CF of this addition;
adc edx,[ebp+$0c]   // edx := edx + y.h + CF; CF = new CF of this addition;
setc byte ptr [ecx] // Carry := CF = 1
end;



function Subtract_uint64_WithBorrow( x, y: uint64; var Borrow: Boolean): uint64;
asm
// The third parameter is in eax .
mov ecx,eax
test byte ptr [ecx], $01 // CF := 0; ZF := not Borrow;
jz @@t1                  // if not ZF then
stc                      //   CF := 1;
@@t1:
mov eax,[ebp+$10]   // eax := x.l;
mov edx,[ebp+$14]   // edx := x.h;
sbb eax,[ebp+$08]   // eax := eax - y.l + (CF * 2^32); CF = new CF of this subtraction;
sbb edx,[ebp+$0c]   // edx := edx - y.h + (CF * 2^32); CF = new CF of this subtraction;
setc byte ptr [ecx] // Borrow := CF = 1
end;




function BitCount_8( Value: byte): integer;
begin
result := 0;
while Value <> 0 do
  begin
  Value := Value shr 1;
  Inc( result)
  end
end;

function BitCount_16( Value: uint16): integer;
begin
result := 0;
while Value <> 0 do
  begin
  Value := Value shr 1;
  Inc( result)
  end
end;

function BitCount_32( Value: uint32): integer;
begin
result := 0;
while Value <> 0 do
  begin
  Value := Value shr 1;
  Inc( result)
  end
end;

function BitCount_64( Value: uint64): integer;
begin
result := 0;
while Value <> 0 do
  begin
  Value := Value shr 1;
  Inc( result)
  end
end;


function CountSetBits_64( Value: uint64): integer;
begin
result := 0;
while Value <> 0 do
  begin
  if Odd( Value) then
    Inc( result);
  Value := Value shr 1
  end
end;

end.
