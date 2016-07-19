////////////////////////////////////////////////////////////////////////////////
//
// Klasa PELock
//
// Wersja         : PELock v2.0
// Jezyk          : D
// Autor          : Bartosz Wójcik (support@pelock.com)
// Strona domowa  : https://www.pelock.com
//
////////////////////////////////////////////////////////////////////////////////

module PELock;

pragma(lib, "kernel32.lib");
pragma(lib, "user32.lib");

import std.string;
import core.runtime;
import core.memory;
import core.sys.windows.windows;

version (Windows)
{
	// prototyp funkcji callback do czytania wlasnego identyfikatora sprzetowego
	extern (Windows) alias DWORD function(LPBYTE) LPHARDWARE_ID_CALLBACK;

	// przykladowa deklaracja
	// extern (Windows) DWORD custom_hardware_id(LPBYTE hardware_id) nothrow
}

class PELock
{
	//
	// max. rozmiar zarejestrowanego uzytkownika, zapisany w kluczu licencyjnym
	//
	const int PELOCK_MAX_USERNAME = 8193;

	//
	// kody bledow z procedur systemu ograniczenia czasowego
	//
	enum TrialCodes
	{
		PELOCK_TRIAL_ABSENT = 0,	// system ograniczenia czasowego nie byl uzyty lub program zarejestrowany
		PELOCK_TRIAL_ACTIVE = 1,	// system ograniczenia czasowego jest aktywny
		PELOCK_TRIAL_EXPIRED = 2	// system ograniczenia czasowego wygasl (zwracane gdy wlaczona jest opcja "Pozwol aplikacji na dzialanie po wygasnieciu"
	};

	//
	// kody bledow z GetKeyStatus()
	//
	enum KeyStatusCodes
	{
		PELOCK_KEY_NOT_FOUND = 0,	// nie znaleziono klucza
		PELOCK_KEY_OK = 1,		// klucz jest poprawny
		PELOCK_KEY_INVALID = 2,		// niepoprawny format klucza
		PELOCK_KEY_STOLEN = 3,		// klucz jest kradziony
		PELOCK_KEY_WRONG_HWID = 4,	// sprzetowy identyfikator nie pasuje
		PELOCK_KEY_EXPIRED = 5		// klucz jest wygasniety
	};

	// odczytaj informacje o statusie klucza licencyjnego
	int GetKeyStatus()
	{
		return (GetWindowText(cast(HWND)-17, null, 256));
	}

	// odczytaj nazwe zarejestrowanego uzytkownika z klucza licencyjnego
	int GetRegistrationName(LPTSTR szRegistrationName, int nMaxCount)
	{
		return (GetWindowText(cast(HWND)-1, szRegistrationName, nMaxCount));
	}

	// odczytaj dane rejestracyjne jako tablice bajtow
	int GetRawRegistrationName(LPVOID lpRegistrationRawName, int nMaxCount)
	{
		return (GetWindowText(cast(HWND)-21, cast(LPTSTR)lpRegistrationRawName, nMaxCount));
	}

	// odczytaj nazwe zarejestrowanego uzytkownika z klucza licencyjnego jako CString
	string GetRegistrationName()
	{
		string szRegistrationName;
		TCHAR[] szTemp = new TCHAR[PELOCK_MAX_USERNAME];

		int iRegistrationNameLen = GetWindowText(cast(HWND)-1, szTemp.ptr, PELOCK_MAX_USERNAME);

		if (iRegistrationNameLen != 0)
		{
			szTemp.length = iRegistrationNameLen;

			szRegistrationName = cast(string)szTemp;
		}

		return szRegistrationName;
	}

	// ustaw sciezke klucza licencyjnego (inna niz katalog programu)
	int SetRegistrationKey(LPTSTR szRegistrationKeyPath)
	{
		return (GetWindowText(cast(HWND)-2, szRegistrationKeyPath, 256));
	}

	// ustaw dane licencyjne z bufora pamieci
	int SetRegistrationData(LPCVOID lpBuffer, int iSize)
	{
		return (GetWindowText(cast(HWND)-7, cast(LPTSTR)lpBuffer, iSize));
	}

	// ustaw dane licencyjne z bufora tekstowego (w formacie MIME Base64)
	int SetRegistrationText(LPTSTR szRegistrationKey)
	{
		return (GetWindowText(cast(HWND)-22, szRegistrationKey, 0));
	}

	// deaktywuj biezacy klucz licencyjny, blokuj mozliwosc ustawienia nowego klucza
	void DisableRegistrationKey(BOOL bPermamentLock)
	{
		GetWindowText(cast(HWND)-14, null, bPermamentLock);
	}

	// przeladuj klucz rejestracyjny z domyslnych lokalizacji
	int ReloadRegistrationKey()
	{
		return GetWindowText(cast(HWND)-16, null, 256);
	}

	// odczytaj wartosci zapisane w kluczu licencyjnym
	int GetKeyData(int iValue)
	{
		return (GetWindowText(cast(HWND)-3, null, iValue));
	}

	// odczytaj wartosci zapisane w kluczu jako bity
	BOOL IsFeatureEnabled(int iIndex)
	{
		return (GetWindowText(cast(HWND)-6, null, iIndex));
	}

	// odczytaj wartosci liczbowe zapisane w kluczu (od 1-16)
	uint GetKeyInteger(int iIndex)
	{
		return (cast(uint)GetWindowText(cast(HWND)-8, null, iIndex));
	}

	// odczytaj sprzetowy identyfikator dla biezacego komputera
	int GetHardwareId(LPTSTR szHardwareId, int nMaxCount)
	{
		return (GetWindowText(cast(HWND)-4, szHardwareId, nMaxCount));
	}

	// odczytaj sprzetowy identyfikator dla biezacego komputera jako CString
	string GetHardwareId()
	{
		string szHardwareId;
		TCHAR[] szTemp = new TCHAR[64];

		int iHardwareIdLen = GetWindowText(cast(HWND)-4, szTemp.ptr, 64);

		if (iHardwareIdLen != 0)
		{
			szTemp.length = iHardwareIdLen;

			szHardwareId = cast(string)szTemp;
		}

		return szHardwareId;
	}

	// ustaw procedure callback do czytania wlasnego identyfikatora sprzetowego
	int SetHardwareIdCallback(LPHARDWARE_ID_CALLBACK lpHardwareIdFunc)
	{
		return (GetWindowText(cast(HWND)-20, cast(LPTSTR)lpHardwareIdFunc, 256));
	}

	// odczytaj date wygasniecia klucza licencyjnego
	int GetKeyExpirationDate(SYSTEMTIME * lpSystemTime)
	{
		return (GetWindowText(cast(HWND)-5, cast(LPTSTR)lpSystemTime, 256));
	}

	// odczytaj date utworzenia klucza licencyjnego
	int GetKeyCreationDate(SYSTEMTIME * lpSystemTime)
	{
		return (GetWindowText(cast(HWND)-15, cast(LPTSTR)lpSystemTime, 256));
	}

	// odczytaj czas wykorzystania klucza (od jego ustawienia)
	int GetKeyRunningTime(SYSTEMTIME * lpRunningTime)
	{
		return (GetWindowText(cast(HWND)-23, cast(LPTSTR)lpRunningTime, 256));
	}


	//
	// funkcje systemu ograniczenia czasowego
	//

	// odczytaj liczbe dni w okresie testowym
	int GetTrialDays(int *dwTotalDays, int *dwLeftDays)
	{
		return (GetWindowText(cast(HWND)-10, cast(LPTSTR)dwTotalDays, cast(int)dwLeftDays));
	}

	// odczytaj liczbe uruchomien w okresie testowym
	int GetTrialExecutions(int *dwTotalExecutions, int *dwLeftExecutions)
	{
		return (GetWindowText(cast(HWND)-11, cast(LPTSTR)dwTotalExecutions, cast(int)dwLeftExecutions));
	}

	// pobierz date wygasniecia aplikacji
	int GetExpirationDate(SYSTEMTIME * lpExpirationDate)
	{
		return (GetWindowText(cast(HWND)-12, cast(LPTSTR)lpExpirationDate, 256));
	}

	// pobierz dane o okresie testowym
	int GetTrialPeriod(SYSTEMTIME * lpPeriodBegin, SYSTEMTIME * lpPeriodEnd)
	{
		return (GetWindowText(cast(HWND)-13, cast(LPTSTR)lpPeriodBegin, cast(int)lpPeriodEnd));
	}


	//
	// wbudowane funkcje szyfrujace
	//

	// funkcje szyfrujace (szyfr strumieniowy)
	int EncryptData(LPCVOID lpKey, int dwKeyLen, LPVOID lpBuffer, int nSize)
	{
		return (cast(int)DeferWindowPos( cast(HDWP)lpKey, cast(HWND)-1, cast(HWND)dwKeyLen, cast(int)lpBuffer, cast(int)nSize, 1, 0, 0 ));
	}

	int DecryptData(LPCVOID lpKey, int dwKeyLen, LPVOID lpBuffer, int nSize)
	{
		return (cast(int)DeferWindowPos( cast(HDWP)lpKey, cast(HWND)-1, cast(HWND)dwKeyLen, cast(int)lpBuffer, cast(int)nSize, 0, 0, 0 ));
	}

	// szyfrowanie danych kluczami dla biezacej sesji procesu
	int EncryptMemory(LPVOID lpBuffer, int nSize)
	{
		return (cast(int)DeferWindowPos( null, cast(HWND)-1, null, cast(int)lpBuffer, cast(int)nSize, 1, 0, 0 ));
	}

	int DecryptMemory(LPVOID lpBuffer, int nSize)
	{
		return (cast(int)DeferWindowPos( null, cast(HWND)-1, null, cast(int)lpBuffer, cast(int)nSize, 0, 0, 0 ));
	}


	//
	// funkcje sprawdzania obecnosci zabezpieczenia PELock'a
	//

	BOOL IsPELockPresent1()
	{
		return ( GetAtomName(0, null, 256) == 1 ? TRUE : FALSE );
	}

	BOOL IsPELockPresent2()
	{
		return ( LockFile(null, 128, 0, 512, 0) == 1 ? TRUE : FALSE );
	}

	BOOL IsPELockPresent3()
	{
		return ( MapViewOfFile(null, FILE_MAP_COPY, 0, 0, 1024) != null ? TRUE : FALSE );
	}

	BOOL IsPELockPresent4()
	{
		return ( SetWindowRgn(null, null, FALSE) == 1 ? TRUE : FALSE );
	}

	BOOL IsPELockPresent5()
	{
		return ( GetWindowRect(null, null) == 1 ? TRUE : FALSE );
	}

	BOOL IsPELockPresent6()
	{
		return ( GetFileAttributes(null) == 1 ? TRUE : FALSE );
	}

	BOOL IsPELockPresent7()
	{
		return ( GetFileTime(null, null, null, null) == 1 ? TRUE : FALSE );
	}

	BOOL IsPELockPresent8()
	{
		return ( SetEndOfFile(null) == 1 ? TRUE : FALSE );
	}

	//
	// chronione wartosci PELock'a
	//

	DWORD PELOCK_DWORD(DWORD dwValue, DWORD dwRandomizer = 0, DWORD dwMagic1 = 0x11223344, DWORD dwMagic2 = 0x44332211)
	{
		DWORD dwReturnValue = 0;
		DWORD[3] dwParams = [0, 0, 0];
		DWORD dwDecodedValue = dwValue - dwRandomizer;

		dwParams[0] = dwDecodedValue;
		dwParams[1] = dwMagic1;
		dwParams[2] = dwMagic2;

		if (GetWindowText( cast(HWND)-9, cast(LPTSTR)&dwReturnValue, cast(int)&dwParams[0]) != 0)
		{
			return dwReturnValue;
		}

		return dwDecodedValue;
	}
}

//
// markery szyfrujace i inne makra
//
version (D_InlineAsm_X86)
{

const SKIP_START = "asm { db 0xEB,0x06,0x8B,0xE4,0x8B,0xC0,0xEB,0xFC; }";
const SKIP_END   = "asm { db 0xEB,0x06,0x8B,0xC0,0x8B,0xE4,0xEB,0xFA; }";

const DEMO_START = "asm { db 0xEB,0x07,0xEB,0xFC,0xEB,0xFA,0xEB,0xFA,0xC7; }";
const DEMO_END   = "asm { db 0xEB,0x06,0xEB,0xFB,0xEB,0xFA,0xEB,0xFC,0xEB,
                             0x06,0xCD,0x20,0xEB,0xFD,0xCD,0x20,0xEB,0x07,
                             0xEB,0xFB,0xEB,0xFA,0xEB,0xFC,0xC8; }";

const FEATURE_1_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x00,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_2_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x01,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_3_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x02,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_4_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x03,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_5_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x04,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_6_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x05,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_7_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x06,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_8_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x07,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_9_START  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x08,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_10_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x09,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_11_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0A,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_12_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0B,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_13_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0C,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_14_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0D,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_15_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0E,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_16_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0F,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_17_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x10,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_18_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x11,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_19_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x12,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_20_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x13,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_21_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x14,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_22_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x15,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_23_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x16,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_24_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x17,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_25_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x18,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_26_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x19,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_27_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1A,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_28_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1B,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_29_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1C,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_30_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1D,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_31_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1E,0xFA,0xEB,0xFA,0xCA; }";
const FEATURE_32_START = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1F,0xFA,0xEB,0xFA,0xCA; }";

const FEATURE_END = "asm { db 0xEB,0x06,0xEB,0xF1,0xEB,0xF2,0xEB,0xF3,0xEB,
                              0x06,0xCD,0x20,0xEB,0xFD,0xCD,0x20,0xEB,0x07,
                              0xEB,0xFB,0xEB,0xFA,0xEB,0xFC,0xCA; }";

alias FEATURE_END FEATURE_1_END;
alias FEATURE_END FEATURE_2_END;
alias FEATURE_END FEATURE_3_END;
alias FEATURE_END FEATURE_4_END;
alias FEATURE_END FEATURE_5_END;
alias FEATURE_END FEATURE_6_END;
alias FEATURE_END FEATURE_7_END;
alias FEATURE_END FEATURE_8_END;
alias FEATURE_END FEATURE_9_END;
alias FEATURE_END FEATURE_10_END;
alias FEATURE_END FEATURE_11_END;
alias FEATURE_END FEATURE_12_END;
alias FEATURE_END FEATURE_13_END;
alias FEATURE_END FEATURE_14_END;
alias FEATURE_END FEATURE_15_END;
alias FEATURE_END FEATURE_16_END;
alias FEATURE_END FEATURE_17_END;
alias FEATURE_END FEATURE_18_END;
alias FEATURE_END FEATURE_19_END;
alias FEATURE_END FEATURE_20_END;
alias FEATURE_END FEATURE_21_END;
alias FEATURE_END FEATURE_22_END;
alias FEATURE_END FEATURE_23_END;
alias FEATURE_END FEATURE_24_END;
alias FEATURE_END FEATURE_25_END;
alias FEATURE_END FEATURE_26_END;
alias FEATURE_END FEATURE_27_END;
alias FEATURE_END FEATURE_28_END;
alias FEATURE_END FEATURE_29_END;
alias FEATURE_END FEATURE_30_END;
alias FEATURE_END FEATURE_31_END;
alias FEATURE_END FEATURE_32_END;

const FEATURE_1_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x00,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_2_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x01,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_3_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x02,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_4_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x03,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_5_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x04,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_6_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x05,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_7_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x06,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_8_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x07,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_9_START_MT  = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x08,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_10_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x09,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_11_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0A,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_12_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0B,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_13_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0C,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_14_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0D,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_15_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0E,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_16_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x0F,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_17_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x10,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_18_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x11,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_19_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x12,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_20_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x13,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_21_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x14,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_22_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x15,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_23_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x16,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_24_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x17,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_25_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x18,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_26_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x19,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_27_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1A,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_28_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1B,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_29_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1C,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_30_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1D,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_31_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1E,0xFA,0xEB,0xFA,0xDA; }";
const FEATURE_32_START_MT = "asm { db 0xEB,0x08,0xEB,0xFC,0xEB,0x1F,0xFA,0xEB,0xFA,0xDA; }";

const FEATURE_END_MT = "asm { db 0xEB,0x06,0xEB,0xF1,0xEB,0xF2,0xEB,0xF3,0xEB,
                                 0x06,0xCD,0x20,0xEB,0xFD,0xCD,0x20,0xEB,0x07,
                                 0xEB,0xFB,0xEB,0xFA,0xEB,0xFC,0xDA; }";

alias FEATURE_END_MT FEATURE_1_END_MT;
alias FEATURE_END_MT FEATURE_2_END_MT;
alias FEATURE_END_MT FEATURE_3_END_MT;
alias FEATURE_END_MT FEATURE_4_END_MT;
alias FEATURE_END_MT FEATURE_5_END_MT;
alias FEATURE_END_MT FEATURE_6_END_MT;
alias FEATURE_END_MT FEATURE_7_END_MT;
alias FEATURE_END_MT FEATURE_8_END_MT;
alias FEATURE_END_MT FEATURE_9_END_MT;
alias FEATURE_END_MT FEATURE_10_END_MT;
alias FEATURE_END_MT FEATURE_11_END_MT;
alias FEATURE_END_MT FEATURE_12_END_MT;
alias FEATURE_END_MT FEATURE_13_END_MT;
alias FEATURE_END_MT FEATURE_14_END_MT;
alias FEATURE_END_MT FEATURE_15_END_MT;
alias FEATURE_END_MT FEATURE_16_END_MT;
alias FEATURE_END_MT FEATURE_17_END_MT;
alias FEATURE_END_MT FEATURE_18_END_MT;
alias FEATURE_END_MT FEATURE_19_END_MT;
alias FEATURE_END_MT FEATURE_20_END_MT;
alias FEATURE_END_MT FEATURE_21_END_MT;
alias FEATURE_END_MT FEATURE_22_END_MT;
alias FEATURE_END_MT FEATURE_23_END_MT;
alias FEATURE_END_MT FEATURE_24_END_MT;
alias FEATURE_END_MT FEATURE_25_END_MT;
alias FEATURE_END_MT FEATURE_26_END_MT;
alias FEATURE_END_MT FEATURE_27_END_MT;
alias FEATURE_END_MT FEATURE_28_END_MT;
alias FEATURE_END_MT FEATURE_29_END_MT;
alias FEATURE_END_MT FEATURE_30_END_MT;
alias FEATURE_END_MT FEATURE_31_END_MT;
alias FEATURE_END_MT FEATURE_32_END_MT;

const UNREGISTERED_START = "asm { db 0xEB,0x07,0xEB,0x02,0xEB,0xFA,0xEB,0x01,0xCB; }";
const UNREGISTERED_END   = "asm { db 0xEB,0x06,0xEB,0x04,0xEB,0x02,0xEB,0x00,0xEB,
                                     0x06,0xCD,0x22,0xEB,0xFC,0xCD,0x22,0xEB,0x07,
                                     0xEB,0xFC,0xEB,0xFC,0xEB,0x01,0xCB; }";

const UNREGISTERED_START_MT = "asm { db 0xEB,0x07,0xEB,0x02,0xEB,0xFA,0xEB,0x01,0xDB; }";
const UNREGISTERED_END_MT   = "asm { db 0xEB,0x06,0xEB,0x04,0xEB,0x02,0xEB,0x00,0xEB,
                                        0x06,0xCD,0x22,0xEB,0xFC,0xCD,0x22,0xEB,0x07,
                                        0xEB,0xFC,0xEB,0xFC,0xEB,0x01,0xDB; }";

const CRYPT_START = "asm { db 0xEB,0x07,0xEB,0x05,0xEB,0x03,0xEB,0x01,0xC7; }";
const CRYPT_END   = "asm { db 0xEB,0x06,0xEB,0x00,0xEB,0x00,0xEB,0x00,0xEB,
                              0x06,0xCD,0x20,0xEB,0xFD,0xCD,0x20,0xEB,0x07,
                              0xEB,0x05,0xEB,0x03,0xEB,0x01,0xC8; }";

const CRYPT_START_MT = "asm { db 0xEB,0x07,0xEB,0x05,0xEB,0x03,0xEB,0x01,0xD7; }";
const CRYPT_END_MT   = "asm { db 0xEB,0x06,0xEB,0x00,0xEB,0x00,0xEB,0x00,0xEB,
                                 0x06,0xCD,0x20,0xEB,0xFD,0xCD,0x20,0xEB,0x07,
                                 0xEB,0x05,0xEB,0x03,0xEB,0x01,0xD8; }";

const CLEAR_START = "asm { db 0xEB,0x07,0xEB,0xFC,0xEB,0x00,0xEB,0x01,0xC9; }";
const CLEAR_END   = "asm { db 0xEB,0x06,0xEB,0x02,0xEB,0xFC,0xEB,0x00,0xEB,
                              0x06,0xCD,0x21,0xEB,0xFA,0xCD,0x21,0xEB,0x07,
                              0xEB,0xFC,0xEB,0xFC,0xEB,0x01,0xC9; }";

const CLEAR_START_MT = "asm { db 0xEB,0x07,0xEB,0xFC,0xEB,0x00,0xEB,0x01,0xD9; }";
const CLEAR_END_MT   = "asm { db 0xEB,0x06,0xEB,0x02,0xEB,0xFC,0xEB,0x00,0xEB,
                                 0x06,0xCD,0x21,0xEB,0xFA,0xCD,0x21,0xEB,0x07,
                                 0xEB,0xFC,0xEB,0xFC,0xEB,0x01,0xD9; }";

const FILE_CRYPT_START = "asm { db 0xEB,0x07,0xEB,0x02,0xEB,0xFC,0xEB,0x01,0xCA; }";
const FILE_CRYPT_END   = "asm { db 0xEB,0x06,0xEB,0xFC,0xEB,0xFC,0xEB,0x00,0xEB,
                                   0x06,0xCD,0x20,0xEB,0xFD,0xCD,0x20,0xEB,0x07,
                                   0xEB,0xFC,0xEB,0x03,0xEB,0xFC,0xCA; }";

const FILE_CRYPT_START_MT = "asm { db 0xEB,0x07,0xEB,0x02,0xEB,0xFC,0xEB,0x01,0xDA; }";
const FILE_CRYPT_END_MT   = "asm { db 0xEB,0x06,0xEB,0xFC,0xEB,0xFC,0xEB,0x00,0xEB,
                                      0x06,0xCD,0x20,0xEB,0xFD,0xCD,0x20,0xEB,0x07,
                                      0xEB,0xFC,0xEB,0x03,0xEB,0xFC,0xDA; }";

const UNPROTECTED_START = "asm { db 0xEB,0x06,0x8B,0xE4,0x89,0xED,0xEB,0xFC; }";
const UNPROTECTED_END   = "asm { db 0xEB,0x06,0x89,0xED,0x8B,0xE4,0xEB,0xFA; }";

const TRIAL_EXPIRED = "asm { db 0xEB,0x08,0x00,0x11,0x22,0x33,0x33,0x22,0x11,0x00; }";

const TRIAL_TOTAL_EXPIRED = "asm { db 0xEB,0x08,0x01,0x11,0x22,0x33,0x33,0x22,0x11,0x00; }";

const PELOCK_CHECKPOINT = "asm { db 0xEB,0x7E,0x0D,0x0A,0x54,0x68,0x72,0x6F,0x75,0x67,0x68,0x20,0x74,0x68,0x65,0x20,
                                    0x64,0x61,0x72,0x6B,0x20,0x6F,0x66,0x20,0x66,0x75,0x74,0x75,0x72,0x65,0x73,0x20,
                                    0x70,0x61,0x73,0x74,0x21,0x0D,0x0A,0x54,0x68,0x65,0x20,0x6D,0x61,0x67,0x69,0x63,
                                    0x69,0x61,0x6E,0x20,0x6C,0x6F,0x6E,0x67,0x73,0x20,0x74,0x6F,0x20,0x73,0x65,0x65,
                                    0x21,0x0D,0x0A,0x4F,0x6E,0x65,0x20,0x63,0x68,0x61,0x6E,0x74,0x73,0x20,0x6F,0x75,
                                    0x74,0x20,0x62,0x65,0x74,0x77,0x65,0x65,0x6E,0x20,0x74,0x77,0x6F,0x20,0x77,0x6F,
                                    0x72,0x6C,0x64,0x73,0x21,0x0D,0x0A,0x46,0x49,0x52,0x45,0x20,0x57,0x41,0x4C,0x4B,
                                    0x20,0x57,0x49,0x54,0x48,0x20,0x4D,0x45,0x21,0x0D,0x0A,0x42,0x4F,0x42,0x0D,0x0A; }";

const PELOCK_MEMORY_GAP = "asm { db 0xE9,0x04,0x20,0x00,0x00,0x8F,0xF1,0x12,0x34;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                                 dl 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; }";

const PELOCK_WATERMARK = "asm { db 0xEB,0x7E,0x44,0x6F,0x77,0x6E,0x20,0x69,0x6E,0x20,0x74,0x68,0x65,0x20,0x70,0x61,
                                   0x72,0x6B,0x0D,0x0A,0x57,0x68,0x65,0x72,0x65,0x20,0x74,0x68,0x65,0x20,0x63,0x68,
                                   0x61,0x6E,0x74,0x20,0x69,0x73,0x20,0x64,0x65,0x61,0x74,0x68,0x2C,0x20,0x64,0x65,
                                   0x61,0x74,0x68,0x2C,0x20,0x64,0x65,0x61,0x74,0x68,0x0D,0x0A,0x55,0x6E,0x74,0x69,
                                   0x6C,0x20,0x74,0x68,0x65,0x20,0x73,0x75,0x6E,0x20,0x63,0x72,0x69,0x65,0x73,0x20,
                                   0x6D,0x6F,0x72,0x6E,0x69,0x6E,0x67,0x0D,0x0A,0x44,0x6F,0x77,0x6E,0x20,0x69,0x6E,
                                   0x20,0x74,0x68,0x65,0x20,0x70,0x61,0x72,0x6B,0x20,0x77,0x69,0x74,0x68,0x20,0x66,
                                   0x72,0x69,0x65,0x6E,0x64,0x73,0x20,0x6F,0x66,0x20,0x6D,0x69,0x6E,0x65,0x0D,0x0A; }";

const PELOCK_CPUID = "asm { db 0xEB,0x7E,0x0D,0x0A,0x0D,0x0A,0x43,0x6F,0x6D,0x65,0x20,0x61,0x73,0x20,0x79,0x6F,
                               0x75,0x20,0x61,0x72,0x65,0x2C,0x20,0x61,0x73,0x20,0x79,0x6F,0x75,0x20,0x77,0x65,
                               0x72,0x65,0x0D,0x0A,0x41,0x73,0x20,0x49,0x20,0x77,0x61,0x6E,0x74,0x20,0x79,0x6F,
                               0x75,0x20,0x74,0x6F,0x20,0x62,0x65,0x0D,0x0A,0x41,0x73,0x20,0x61,0x20,0x66,0x72,
                               0x69,0x65,0x6E,0x64,0x2C,0x20,0x61,0x73,0x20,0x61,0x20,0x66,0x72,0x69,0x65,0x6E,
                               0x64,0x0D,0x0A,0x41,0x73,0x20,0x61,0x6E,0x20,0x6F,0x6C,0x64,0x20,0x65,0x6E,0x65,
                               0x6D,0x79,0x0D,0x0A,0x54,0x61,0x6B,0x65,0x20,0x79,0x6F,0x75,0x72,0x20,0x74,0x69,
                               0x6D,0x65,0x2C,0x20,0x68,0x75,0x72,0x72,0x79,0x20,0x75,0x70,0x0D,0x0A,0x0D,0x0A; }";

const PELOCK_INIT_CALLBACK = "asm { db 0xEB,0x08,0x10,0x11,0x22,0x33,0x33,0x22,0x11,0x00; }";

const HARDWARE_ID_CALLBACK = "asm { db 0xEB,0x08,0x4F,0x5A,0xF7,0x38,0x31,0xCD,0xE0,0x53; }";

}
