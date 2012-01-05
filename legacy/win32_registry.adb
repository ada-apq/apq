-- $Id: win32_registry.adb,v 1.1 2003/09/24 14:16:58 wwg Exp $
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

with Ada.Unchecked_Conversion;
with Ada.Characters.Latin_1;
with Win32.WinReg;
with Win32.Winnt;
with Win32.WinError;
with Interfaces.C;

package body Win32_Registry is

   procedure Raise_Error(Result : Win32.LONG) is
      use Win32.WinError;
   begin
      case Result is
         when ERROR_SUCCESS =>
            return;           -- Not really an error!
         when ERROR_FILE_NOT_FOUND =>
            raise Not_Found;
         when others =>
            raise Failed;
      end case;
   end Raise_Error;

   function To_String(Buffer : Win32.Byte_Array) return String is
      function To_Char is new Ada.Unchecked_Conversion(Win32.BYTE,Character);
      S : String(Buffer'Range);
   begin
      declare
      begin
         for X in S'Range loop
            S(X) := To_Char(Buffer(X));
         end loop;
         return S;
      end;
   end To_String;

   function To_String(Buffer : Win32.Byte_Array; Count : Win32.DWORD) return String is
      use Interfaces.C;
   begin
      if Count = 0 then
         return "";
      end if;
      declare
         S_Count : Win32.DWORD := Count - 1;
         S_Last :  Integer := Buffer'First + Integer(S_Count) - 1;
      begin
         return To_String(Buffer(Buffer'First..S_Last));
      end;
   end To_String;

   function Open(hKey : HKEY_Type; Key : String) return HKEY_Type is
      use Win32.WinReg, Interfaces.C;

      NUL :       constant Character := Ada.Characters.Latin_1.NUL;
      Root_Key :  constant String := Key & NUL;
      H :         aliased HKEY_Type;
      Result :    Win32.LONG;
   begin

      Result := RegOpenKeyExA(
         hKey           => hKey,
         lpSubKey       => Win32.Addr(Root_Key),
         ulOptions      => 0,
         samDesired     => Win32.Winnt.KEY_READ,
         phkResult      => H'Unrestricted_Access
      );

      if Result /= Win32.WinError.ERROR_SUCCESS then
         Raise_Error(Result);
      end if;

      return H;
   end Open;

   procedure Close(hKey : HKEY_Type) is
      use Interfaces.C;
      Result : Win32.LONG;
   begin
      Result := Win32.WinReg.RegCloseKey(hKey);
      if Result /= 0 then
         raise Failed;
      end if;
   end Close;

   function Query(hKey : HKEY_Type; Key : String) return String is
      use Win32.WinReg, Interfaces.C;

      NUL :       constant Character := Ada.Characters.Latin_1.NUL;
      Result :    Win32.LONG;

      Value_Key : String := Key & NUL;
      Value_Buf : Win32.BYTE_Array(1..1024) := (others => 0);
      DType :     aliased Win32.DWORD;
      Count :     aliased Win32.DWORD := Value_Buf'Length;
   begin

      Result := RegQueryValueExA(
         hKey           => hKey,
         lpValueName    => Win32.Addr(Value_Key),
         lpReserved     => null,
         lpType         => DType'Unrestricted_Access,
         lpData         => Value_Buf(1)'Unrestricted_Access,
         lpcbData       => Count'Unrestricted_Access
      );

      if Result /= Win32.WinError.ERROR_SUCCESS then
         Raise_Error(Result);
      end if;

      if DType /= Win32.Winnt.REG_SZ then
         raise Wrong_Type;    -- Incorrect Data Type
      end if;

      return To_String(Value_Buf,Count);
   end Query;

end Win32_Registry;
