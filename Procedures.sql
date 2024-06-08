-- Skladanie Zamowien
SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE PaliwoTyp AS OBJECT (
    PaliwoID NUMBER,
    Ilosc NUMBER
);
/

CREATE OR REPLACE TYPE PaliwaTyp AS TABLE OF PaliwoTyp;
/

-- Procedura składania zamówienia
CREATE OR REPLACE PROCEDURE zloz_zamowienie(
    p_Paliwa PaliwaTyp
)
IS
    v_ZamowienieID Zamowienia.ZamowienieID%TYPE;
    i NUMBER;
    v_cenaZaLitr NUMBER;
    v_kwota NUMBER := 0;
BEGIN 
    INSERT INTO Zamowienia (DataZamowienia, Kwota, Status)
    VALUES (SYSDATE, 0, 'Zamówione')
    RETURNING ZamowienieID INTO v_ZamowienieID;

    DBMS_OUTPUT.PUT_LINE('Dodano zamówienie ID = ' || v_ZamowienieID);
    
    FOR i IN p_Paliwa.FIRST .. p_Paliwa.LAST LOOP
        SELECT cenazalitr INTO v_cenaZaLitr FROM Paliwa WHERE PaliwoID = p_Paliwa(i).PaliwoID;
        v_kwota := v_kwota + (v_cenaZaLitr * p_Paliwa(i).Ilosc);
        INSERT INTO SzczegolyZamowienia (ZamowienieID, PaliwoID, Ilosc, CenaZaLitr)
        VALUES (v_ZamowienieID, p_Paliwa(i).PaliwoID, p_Paliwa(i).Ilosc, v_cenaZaLitr);

        DBMS_OUTPUT.PUT_LINE('Dodano szczegóły zamówienia dla PaliwoID = ' || p_Paliwa(i).PaliwoID);
    END LOOP;
    
    UPDATE Zamowienia SET Kwota = v_kwota 
    WHERE ZamowienieID = v_ZamowienieID;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

DECLARE 
    v_Paliwa PaliwaTyp := PaliwaTyp();
BEGIN 
    v_Paliwa.EXTEND;
    v_Paliwa(v_Paliwa.COUNT) := PaliwoTyp(1, 1500);
    v_Paliwa.EXTEND;
    v_Paliwa(v_Paliwa.COUNT) := PaliwoTyp(2, 2790);

    zloz_zamowienie(v_Paliwa);
END;
/
-- Przyjmowanie towaru ( na podstawie zamowien) 

CREATE OR REPLACE PROCEDURE przyjmij_towar(
    p_ZamowienieID IN NUMBER
)
IS
    v_Ilosc NUMBER;
    v_PaliwoID NUMBER;
    v_AktualnyStan NUMBER;
    v_PracownikID NUMBER;
    CURSOR c_zamowienia IS 
        SELECT PaliwoID, Ilosc
        FROM SzczegolyZamowienia    
        WHERE ZamowienieID = p_ZamowienieID;
BEGIN 

    SELECT p.PracownikID INTO v_PracownikID
    FROM pracownicy p
    JOIN PracownicyZmiany pz ON p.PracownikID = pz.PracownikID
    JOIN Zmiany z ON pz.ZmianaID = z.zmianaID
    WHERE SYSDATE BETWEEN z.GodzinaRozpoczecia AND z.godzinaZakonczenia 
    AND p.stanowisko = 'Kierownik';
    
    FOR rec IN c_zamowienia LOOP
        SELECT AktualnyStan INTO v_AktualnyStan
        FROM Paliwa
        WHERE PaliwoID = rec.PaliwoID;
        
        v_AktualnyStan := v_AktualnyStan + rec.Ilosc;
    
        UPDATE Paliwa 
        SET AktualnyStan = v_AktualnyStan
        WHERE PaliwoID = rec.PaliwoID;
        
        DBMS_OUTPUT.PUT_LINE('Rozliczono zamówienie dla PaliwoID = ' || rec.PaliwoID);
    END LOOP;
    
    UPDATE Zamowienia
    SET Status = 'Przyjęte', OdbiorcaID = v_PracownikID
    WHERE ZamowienieID = p_ZamowienieID;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

BEGIN
    przyjmij_towar(1);
END;
/
-- Rozliczanie sie z dostawcami


CREATE OR REPLACE PROCEDURE rozlicz_z_dostawca(
p_zamowienieID IN NUMBER)
IS
BEGIN
    UPDATE Zamowienia
    SET Status = 'Opłacone'
    WHERE Status = 'Przyjęte' AND ZamowienieID = p_zamowienieID;
    DBMS_OUTPUT.PUT_LINE('Zamówienie ID = ' || p_ZamowienieID || ' zostało opłacone.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR : ' ||  SQLERRM);
        ROLLBACK;
END;
/
BEGIN
    rozlicz_z_dostawca(1);
END;
/



-- Monitorowac aktualny stan paliw  aby moc zlozyc zamowienie w odpowiednim czasie

CREATE OR REPLACE PROCEDURE monitoruj_stan_paliw(
    p_paliwoID IN NUMBER
)
IS
    v_aktualnyStan NUMBER;
    v_paliwa PaliwaTyp := PaliwaTyp();
BEGIN
    SELECT AktualnyStan INTO v_aktualnyStan
    FROM Paliwa 
    WHERE PaliwoID = p_paliwoID;
    
    IF v_aktualnyStan < 5000 THEN
        DBMS_OUTPUT.PUT_LINE('Stan paliwa poniżej normy dla PaliwoID = ' || p_paliwoID || '. Aktualny stan wynosi: ' || v_aktualnyStan);
        
        v_paliwa.EXTEND;
        v_paliwa(v_paliwa.COUNT) := PaliwoTyp(p_paliwoID,10000);
        zloz_zamowienie(v_Paliwa);        
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
        ROLLBACK;
END;
/
CREATE OR REPLACE TRIGGER monitoruj_stan_paliw_trigger
AFTER INSERT ON SzczegolyTransakcji
FOR EACH ROW
BEGIN 
    monitoruj_stan_paliw(:NEW.PaliwoID);
END;
/


CREATE OR REPLACE TYPE sprzedaz_pracownik_typ AS OBJECT(
    pracownikID NUMBER,
    imie VARCHAR2(50),
    nazwisko VARCHAR2(50),
    ilosc_paliwa NUMBER,
    wartosc_sprzedazy NUMBER
);
/

CREATE OR REPLACE TYPE sprzedaze_pracownikow_typ AS TABLE OF sprzedaz_pracownik_typ;
/

-- Raporty ilosciowe wartosciowe sprzedazy w ujeciu pracownika
CREATE OR REPLACE FUNCTION raport_sprzedazy_pracownika(
    p_pracownikID INT    
)
RETURN sprzedaze_pracownikow_typ
IS
    v_sprzedaze sprzedaze_pracownikow_typ := sprzedaze_pracownikow_typ();
    licznik_tabeli INT := 1;
    
    CURSOR c (c_pracownikID INT) IS
        SELECT p.pracownikID, p.imie, p.nazwisko, SUM(st.IloscPaliwa) AS ilosc_paliwa, SUM(st.kwota) AS wartosc_sprzedazy
        FROM Pracownicy p
        JOIN SzczegolyTransakcji st ON st.ObslugujacyID = p.PracownikID
        WHERE p.PracownikID = c_pracownikID
        GROUP BY p.pracownikID, p.imie, p.nazwisko;
BEGIN
    FOR i IN c(p_pracownikID) LOOP
        v_sprzedaze.EXTEND;
        v_sprzedaze(licznik_tabeli) := sprzedaz_pracownik_typ(i.pracownikID, i.imie, i.nazwisko, i.ilosc_paliwa, i.wartosc_sprzedazy);
        licznik_tabeli := licznik_tabeli + 1;
    END LOOP;
    RETURN v_sprzedaze;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RETURN NULL;
END;
/

SELECT *
FROM TABLE(raport_sprzedazy_pracownika(7));


-- Raporty ilosciowe wartosciowe sprzedazy w ujeciu danegotypu paliwa

CREATE OR REPLACE TYPE sprzedaz_typ_paliwa AS OBJECT(
    rodzaj_paliwa VARCHAR2(50),
    ilosc_paliwa NUMBER,
    wartosc_sprzedazy NUMBER
);
/

CREATE OR REPLACE TYPE sprzedaze_typow_paliwa AS TABLE OF sprzedaz_typ_paliwa;
/

CREATE OR REPLACE FUNCTION raport_sprzedazy_typu_paliwa(
    p_rodzaj_paliwa VARCHAR2    
)
RETURN sprzedaze_typow_paliwa
IS
    v_sprzedaze sprzedaze_typow_paliwa := sprzedaze_typow_paliwa();
    licznik_tabeli INT := 1;
    
    CURSOR c (c_rodzaj_paliwa VARCHAR2) IS
        SELECT p.RodzajPaliwa, SUM(st.IloscPaliwa) AS ilosc_paliwa, SUM(st.kwota) AS wartosc_sprzedazy
        FROM Paliwa p
        JOIN SzczegolyTransakcji st ON st.PaliwoID = p.PaliwoID
        WHERE p.RodzajPaliwa = c_rodzaj_paliwa
        GROUP BY p.RodzajPaliwa;
BEGIN
    FOR i IN c(p_rodzaj_paliwa) LOOP
        v_sprzedaze.EXTEND;
        v_sprzedaze(licznik_tabeli) := sprzedaz_typ_paliwa(i.RodzajPaliwa, i.ilosc_paliwa, i.wartosc_sprzedazy);
        licznik_tabeli := licznik_tabeli + 1;
    END LOOP;
    RETURN v_sprzedaze;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RETURN NULL;
END;
/

SELECT *
FROM TABLE(raport_sprzedazy_typu_paliwa('Benzyna'));


-- Raporty ilosciowe wartosciowe sprzedazy w ujeciu dostawce paliwa


CREATE OR REPLACE TYPE sprzedaz_dostawca_typ AS OBJECT(
    dostawcaID NUMBER,
    nazwa VARCHAR2(255),
    ilosc_paliwa NUMBER,
    wartosc_sprzedazy NUMBER
);
/

CREATE OR REPLACE TYPE sprzedaze_dostawcow_typ AS TABLE OF sprzedaz_dostawca_typ;
/


CREATE OR REPLACE FUNCTION raport_sprzedazy_dostawcy(
    p_dostawcaID INT    
)
RETURN sprzedaze_dostawcow_typ
IS
    v_sprzedaze sprzedaze_dostawcow_typ := sprzedaze_dostawcow_typ();
    licznik_tabeli INT := 1;
    
    CURSOR c (c_dostawcaID INT) IS
        SELECT d.DostawcaID, d.Nazwa, SUM(st.IloscPaliwa) AS ilosc_paliwa, SUM(st.kwota) AS wartosc_sprzedazy
        FROM Dostawcy d
        JOIN Paliwa p ON p.DostawcaID = d.DostawcaID
        JOIN SzczegolyTransakcji st ON st.PaliwoID = p.PaliwoID
        WHERE d.DostawcaID = c_dostawcaID
        GROUP BY d.DostawcaID, d.Nazwa;
BEGIN
    FOR i IN c(p_dostawcaID) LOOP
        v_sprzedaze.EXTEND;
        v_sprzedaze(licznik_tabeli) := sprzedaz_dostawca_typ(i.DostawcaID, i.Nazwa, i.ilosc_paliwa, i.wartosc_sprzedazy);
        licznik_tabeli := licznik_tabeli + 1;
    END LOOP;
    RETURN v_sprzedaze;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RETURN NULL;
END;
/

SELECT *
FROM TABLE(raport_sprzedazy_dostawcy(1));
-- ustalenie premii dla pracownikow - raporty ilosciowo wartosciowe sprzedazy
DROP FUNCTION oblicz_premie_pracownikow;
CREATE OR REPLACE PROCEDURE oblicz_premie_pracownikow IS
    CURSOR c_pracownicy IS
        SELECT p.PracownikID, SUM(pr.Punkty) AS punkty
        FROM Pracownicy p
        JOIN PremiePracownikow pr ON pr.PracownikID = p.PracownikID
        GROUP BY p.PracownikID;

    v_premia NUMBER;
BEGIN
    FOR rec IN c_pracownicy LOOP
        IF rec.punkty >= 200 THEN
            v_premia := 500;
        ELSIF rec.punkty >= 150 THEN
            v_premia := 200;
        ELSIF rec.punkty >= 100 THEN
            v_premia := 100;
        ELSE
            v_premia := 0;
        END IF;

        DBMS_OUTPUT.PUT_LINE('Premia dla pracownika ID ' || rec.PracownikID || ' wynosi ' || v_premia || ' zł.');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/

BEGIN
    oblicz_premie_pracownikow;
END;
/


-- raporty ilościowo wartościowe sprzedaży

-- Wystawianie faktur dla klientow ktorzy dokonali zakupu

CREATE OR REPLACE PROCEDURE wystaw_fakture(
    p_klientID IN NUMBER,
    p_transakcjaID IN NUMBER,
    p_nip IN VARCHAR2
)
IS
BEGIN
    INSERT INTO Faktury (FakturaID, KlientID, TransakcjaID, NIP)
    VALUES (seq_FakturaID.NEXTVAL, p_klientID, p_transakcjaID, p_nip);

    DBMS_OUTPUT.PUT_LINE('Faktura wystawiona dla KlientID = ' || p_klientID || ', TransakcjaID = ' || p_transakcjaID);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END;
/

BEGIN
    wystaw_fakture(1, 1, '1234567890');
END;
/
