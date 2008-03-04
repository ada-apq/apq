-- $Id: win32_gnat_info.adb,v 1.2 2003/09/24 15:44:43 wwg Exp $
-- Copyright (c) 2002, Warren W. Gay VE3WWG
--
-- Licensed under the ACL (Ada Community License)
-- or
-- GNU Public License 2 (GPL2)
-- 
--     This program is free software; you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation; either version 2 of the License, or
--     (at your option) any later version.
-- 
--     This program is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
-- 
--     You should have received a copy of the GNU General Public License
--     along with this program; if not, write to the Free Software
--     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

with Ada.Strings.Fixed;
with Interfaces.C;
with GNAT.OS_Lib;
with GNAT.Directory_Operations;
with WIn32.WinReg;
with Win32_Registry;

package body Win32_GNAT_Info is

   Top_Level_Key :   constant String := "SOFTWARE\Ada Core Technologies";
   GNAT_Level_Key :  constant String := Top_Level_Key & "\GNAT";
   Std_Lib_Key :     constant String := GNAT_Level_Key & "\Standard Libraries";

   Root_Subkey :     constant String := "ROOT";       -- Under GNAT_Level_Key
   Vers_Subkey :     constant String := "VERSION";    -- Under Top_Level_Key
   Win32Ada_Subkey : constant String := "WIN32ADA";   -- Under Std_Lib_Key

   function Dir_Name(Path : String) return String is
      use Ada.Strings.Fixed;
      X : Natural;
   begin
      X := Index(Source => Path, Pattern => "\", Going => Ada.Strings.Backward);
      if X < Path'First then
         return Path;
      else
         return Path(1..X-1);
      end if;
   end Dir_Name;

   procedure Not_Dot_Dir_Entry(Dir : in out GNAT.Directory_Operations.Dir_Type; Name : in out String; Last : out Natural) is
      use GNAT.Directory_Operations;
   begin
      loop
         Read(Dir,Name,Last);
         exit when Last < Name'First;     -- End of directory
         exit when Name(Name'First..Last) /= "." and then Name(Name'First..Last) /= "..";
      end loop;
   end Not_Dot_Dir_Entry;

   function ADAINCLUDE_Parent return String is
      use GNAT.Directory_Operations;
      Start_Dir : String := Root & "\LIB\GCC-LIB";
      Dir :       Dir_Type;
      Name :      String(1..1024);
      Last :      Natural := 0;
   begin
      begin
         Open(Dir,Start_Dir);
      exception
         when others =>
            raise Failed;
      end;

      begin
         loop
            Not_Dot_Dir_Entry(Dir,Name,Last);
            exit when Last < Name'First;
            exit when Ada.Strings.Fixed.Index(Name(Name'First..Last),"mingw32") >= Name'First;
         end loop;

         if Last < Name'First then
            Close(Dir);
            raise Failed;        -- GNAT must be using a different directory structure
         end if;

         declare
            Dive_Dir :  String := Start_Dir & "\" & Name(Name'First..Last);
         begin
            Close(Dir);
            Open(Dir,Dive_Dir);

            loop
               Not_Dot_Dir_Entry(Dir,Name,Last);
               exit when Last < Name'First;
               exit when Name(Name'First) in '0'..'9' and Name(Name'First+1) = '.'
                  and Name(Name'First+2) in '0'..'9';
            end loop;

            Close(Dir);
            if Last < Name'First then
               raise Failed;
            end if;
            return Dive_Dir & "\" & Name(Name'First..Last);
         end;
      exception
         when others =>
            Close(Dir);
            raise Failed;
      end;
   end ADAINCLUDE_Parent;

--------------------------------------------------------------------------------

   ------------------------------
   -- RETURN THE ROOT DIRECTORY FOR THE INSTALLED
   -- GNAT COMPILER AND TOOLS :
   ------------------------------

   function Root return String is
      use Win32_Registry;
      H : HKEY_Type;
   begin

      H := Open(HKEY_LOCAL_MACHINE,GNAT_Level_Key);
      declare
         S : String := Win32_Registry.Query(H,Root_Subkey);
      begin
         Close(H);
         return S;
      exception
         when others =>
            Close(H);
            raise;
      end;
   end Root;

   ------------------------------
   -- RETURN THE GNAT COMPILER VERSION
   -- STRING (E.G. "3.14P")
   ------------------------------

   function Version return String is
      use Win32_Registry;
      H : HKEY_Type;
   begin

      H := Open(HKEY_LOCAL_MACHINE,Top_Level_Key);
      declare
         S : String := Win32_Registry.Query(H,Vers_Subkey);
      begin
         Close(H);
         return S;
      exception
         when others =>
            Close(H);
            raise;
      end;
   end Version;

   ------------------------------
   -- RETURN THE APQ VERSION IF THE
   -- BINDING IS INSTALLED.
   ------------------------------

   function APQ_Version return String is
      use Win32_Registry;
      H : HKEY_Type;
   begin

      H := Open(HKEY_LOCAL_MACHINE,"SOFTWARE\APQ");
      declare
         S : String := Win32_Registry.Query(H,"Version");
      begin
         Close(H);
         return S;
      exception
         when others =>
            Close(H);
            raise;
      end;
   end APQ_Version;

   ------------------------------
   -- RETURN THE DIRECTORY NAME FOR GNAT
   -- Win32Ada BINDINGS (E.G. "C:\OPT\GNAT\BINDINGS\Win32Ada")
   ------------------------------

   function Win32Ada_Bindings_Directory return String is
      use Win32_Registry;
      H :               HKEY_Type;
   begin

      H := Open(HKEY_LOCAL_MACHINE,Std_Lib_Key);
      declare
         S : String := Win32_Registry.Query(H,Win32Ada_Subkey);
      begin
         Close(H);
         return S;
      exception
         when others =>
            Close(H);
            raise;
      end;
   end Win32Ada_Bindings_Directory;
   
   ------------------------------
   -- RETURN THE DIRECTORY NAME FOR GNAT
   -- BINDINGS (E.G. "C:\OPT\GNAT\BINDINGS")
   ------------------------------

   function Bindings_Directory return String is
      Win32Ada_Dir : String := Win32Ada_Bindings_Directory;
   begin
      return Dir_Name(Win32Ada_Dir);
   end Bindings_Directory;
   
   ------------------------------
   -- RETURN THE PATH OF GNAT
   -- BIN DIRECTORY (e.g.
   -- "C:\OPT\GNAT\bin"
   ------------------------------

   function Bin return String is
   begin
      return Root & "\BIN";
   end Bin;

   ------------------------------
   -- RETURN THE PATH TO THE ADAINLCUDE
   -- DIRECTORY :
   ------------------------------

   function ADAINCLUDE return String is
   begin
      return ADAINCLUDE_Parent & "\adainclude";
   end ADAINCLUDE;

   ------------------------------
   -- RETURN THE PATH TO THE ADALIB
   -- DIRECTORY :
   ------------------------------

   function ADALIB return String is
   begin
      return ADAINCLUDE_Parent & "\adalib";
   end ADALIB;

   ------------------------------
   -- RETURN THE ADA_INCLUDE_PATH
   -- ENVIRONMENT VARIABLE VALUE :
   ------------------------------

   function ADA_INCLUDE_PATH return string is
      use GNAT.OS_Lib;

      Var_Ptr : String_Access := GetEnv("ADA_INCLUDE_PATH");
   begin
      if Var_Ptr = null then
         return "";
      end if;
      return Var_Ptr.all;
   end ADA_INCLUDE_PATH;

   ------------------------------
   -- RETURN THE ADA_OBJECTS_PATH
   -- ENVIRONMENT VARIABLE VALUE :
   ------------------------------

   function ADA_OBJECTS_PATH return string is
      use GNAT.OS_Lib;

      Var_Ptr : String_Access := GetEnv("ADA_OBJECTS_PATH");
   begin
      if Var_Ptr = null then
         return "";
      end if;
      return Var_Ptr.all;
   end ADA_OBJECTS_PATH;

end Win32_GNAT_Info;
