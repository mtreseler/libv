-- To the extent possible under law,
-- Martin Thompson and Hendrick Eeckhaut
-- have waived all copyright and related or neighbouring
-- rights to the libv project.
-- This work is published from: United Kingdom.

package libv is
    -- VHDL-2008 users will have to comment this line out as it's
    -- a default part of that standard
    type integer_vector is array(natural range <>) of integer;

    function max (a, b : integer) return integer;
    
    -- Function: number of bits
    -- returns number of bits required to represent 'value'
    function number_of_bits (value : positive) return positive;

    function number_of_chars (val : integer) return integer;
    
    -- Function: echo
    -- writes one string to "STD_OUTPUT" without a line feed
    procedure echo ( val : string := "");        
    procedure assert_equal (prefix : string; got, expected : integer; level: severity_level := error);
    procedure assert_equal (prefix : string; got, expected : string; level: severity_level := error);
    procedure assert_equal (prefix : string; got, expected : integer_vector; level : severity_level := error);

    function str (val : integer; length : natural := 0) return string;
    function str (val : boolean; length : natural range 0 to 1 := 0) return string;

end package libv;

package body libv is
  
    function max (a,b : integer) return integer is
    begin  -- function max
        if a > b then
            return a;
        else
            return b;
        end if;
    end function max;
    
    function number_of_chars (val : integer) return integer is
        variable temp : integer;
        variable chars_needed : natural := 0;
    begin  -- function number_of_chars
        if val <= 0 then
             chars_needed := 1;  -- start needing one char for potential '-' sign or for the zero itself
        end if;
        temp := abs(val);
        while temp > 0 loop
            temp := temp / 10;
            chars_needed := chars_needed + 1;
        end loop;
        return chars_needed;
    end function number_of_chars;

    -- Function: str(integer)
    -- Takes an integer and optional length.  If length is zero, simply returns a string representing the integer
    -- If length is too short to hold the string, then the whole string is also returned
    -- If length is longer than the integer, the string representation will be right-aligned within a string 1 to length 
    function str (val : integer; length : natural := 0) return string is
        constant chars_needed : natural := number_of_chars(val);
        variable s : string(1 to max(length, chars_needed)) := (others => ' ');
    begin  -- function str
        if length = 0 then
            return integer'image(val);
        end if;
        if chars_needed > length then
            report "Can't fit " & integer'image(val) & " into " & integer'image(length) & " character(s) - returning full width" severity warning;
            return integer'image(val);
        end if;
        s(s'high-(chars_needed-1) to s'high) := integer'image(val);
        return s;
    end function str;

    
    -- Function: str(boolean, length)
    -- Takes a boolean and optional length.
    -- If length is 0, simply returns a string "True" or "False"
    -- If length is 1, returns "T" or "F"
    function str (val : boolean; length:natural range 0 to 1 := 0) return string is
    begin  -- function str
        if length = 0 then
            return boolean'image(val);
        end if;
        if length = 1 then
            if val then
                return "T";
            else
                return "F";
            end if;
        end if;
    end function str;
    ------------------------------------------------------------------------------------------------------------------------------
    
    function number_of_bits (
        value : positive)
        return positive is
        variable bits : positive := 1;
    begin  -- function number_of_bits
        while 2**bits <= value loop
            bits := bits + 1;
        end loop;
        return bits;
    end function number_of_bits;

    procedure echo ( -- write one string to "STD_OUTPUT" without a line feed
        val : in string := "") is
    begin
      std.textio.write(std.textio.output, val);
    end procedure echo;

    procedure assert_equal (
        prefix        : string;
        got, expected : integer;
        level : severity_level := error) is
    begin  -- procedure assert_equal
        assert got = expected
            report prefix & " wrong.  Got " & str(got) & " expected " & str(expected) & "(difference=" & str(got-expected) &")"
            severity level;
    end procedure assert_equal;
    
    procedure assert_equal (
        prefix        : string;
        got, expected : string;
        level : severity_level := error) is
    begin  -- procedure assert_equal        
        assert got = expected
            report prefix & " wrong.  Got " & got & " expected " & expected &")"
            severity level;
    end procedure assert_equal;

    procedure assert_equal (
        prefix        : string;
        got, expected : integer_vector;
        level : severity_level := error) is 
        variable g,e : integer;
        constant top : integer := got'length-1;
    begin  -- procedure assert_equal
        assert got'length = expected'length
            report prefix & " length wrong.  Got " & str(got'length)
            & " expected " & str(expected'length)
            & "(difference=" & str(got'length-expected'length) &")"
            severity level;
        for i in 0 to top loop
            g := got(got'low+i);
            e := expected(expected'low+i);
            assert g = e
                report prefix & CR & LF
                & "       got(" & str(got'low+i) & ") = " & str(g) & CR & LF
                & "  expected(" & str(expected'low+i) & ") = " & str(e)
                severity level;
        end loop;  -- i
    end procedure assert_equal;
end package body libv;

entity tb_libv is
    
end entity tb_libv;
use work.libv.all;
architecture test of tb_libv is
begin  -- architecture test

    test: process is
    begin
        echo ( "______________________ Testing procedure tb_libv" & LF&LF);     
        assert_equal("max", max(1,4), 4);
        assert_equal("max", max(1,1), 1);
        assert_equal("max", max(-1,1), 1);
        assert_equal("max", max(-1,-5), -1);
    
        assert_equal("number_of_chars", number_of_chars(1), 1);
        assert_equal("number_of_chars", number_of_chars(-1), 2);
        assert_equal("number_of_chars", number_of_chars(9), 1);
        assert_equal("number_of_chars", number_of_chars(-9), 2);
        assert_equal("number_of_chars", number_of_chars(19), 2);
        assert_equal("number_of_chars", number_of_chars(1999), 4);
        assert_equal("number_of_chars", number_of_chars(-9999), 5);

        assert_equal("number_of_bits", number_of_bits(1), 1);
        assert_equal("number_of_bits", number_of_bits(2), 2);
        assert_equal("number_of_bits", number_of_bits(3), 2);
        assert_equal("number_of_bits", number_of_bits(7), 3);
        assert_equal("number_of_bits", number_of_bits(8), 4);
        assert_equal("number_of_bits", number_of_bits(200), 8);
        assert_equal("number_of_bits", number_of_bits(1200), 11);

        assert_equal("str(int)", str(0), "0");
        assert_equal("str(int)", str(10), "10");
        assert_equal("str(int)", str(-10), "-10");
        assert_equal("str(int)", str(0,1), "0");
        assert_equal("str(int)", str(0,2), " 0");
        
        assert_equal("str(int)", str(10,4), "  10");
        assert_equal("str(int)", str(-10,4), " -10");
        
        assert_equal("str(boolean)", str(false), "false");
        assert_equal("str(boolean)", str(true), "true");
        assert_equal("str(boolean)", str(false,1), "F");
        assert_equal("str(boolean)", str(true,1), "T");
        echo ("No assertions expected above here __^" & LF&LF);     
        
        assert_equal("str(int)", str(10,1), "10");   
        echo("______________________fit warning expected above ^" & LF&LF);
        
        assert_equal("str(int)", str(-10,1), "-10"); 
        echo("______________________fit warning expected above ^" & LF&LF);

        report test'path_name & "Tests complete" severity note;
        wait;
    end process;

end architecture test;

-- Expected output:
--
--# ______________________ Testing procedure tb_libv
--# 
--# No assertions expected above here __^
--# 
--# ** Warning: Can't fit 10 into 1 character(s) - returning full width
--#    Time: 0 ps  Iteration: 0  Instance: /tb_libv
--# ______________________fit warning expected above ^
--# 
--# ** Warning: Can't fit -10 into 1 character(s) - returning full width
--#    Time: 0 ps  Iteration: 0  Instance: /tb_libv
--# ______________________fit warning expected above ^
--# 
--# ** Note: :tb_libv:test:Tests complete
--#    Time: 0 ps  Iteration: 0  Instance: /tb_libv
