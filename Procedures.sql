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



CREATE OR REPLACE FUNCTION raport_sprzedazy_pracownika(
    p_pracownikID INT    
)
RETURN sprzedaz_pracownik_typ
IS
    v_sprzedaz sprzedaz_pracownik_typ;
    
    
    CURSOR c (c_p_pracownikID INT ) IS
        SELECT p.pracownikID,
                p.imie,
                 p.nazwisko,
            SUM(st.IloscPaliwa),
            SUM(st.kwota)
            INTO v_sprzedaz
            FROM Pracownicy p
            JOIN SzczegolyTransakcji st ON st.ObslugujacyID = p.PracownikID
            GROUP BY p.pracownikID, p.Imie, p.Nazwisko;
BEGIN

    
    
    
    RETURN v_sprzedaz;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    RETURN NULL;
END;
/

SELECT raport_sprzedazy_pracownika(7) FROM DUAL;

-- Rozliczanie sprzeadzy zmiany
-- Raporty ilosciowe wartosciowe sprzedazy w ujeciu pracownika
-- Raporty ilosciowe wartosciowe sprzedazy w ujeciu danegotypu paliwa
-- Raporty ilosciowe wartosciowe sprzedazy w ujeciu dostawce paliwa
-- ustalenie premii dla pracownikow - raporty ilosciowo wartosciowe sprzedazy
-- raporty ilościowo wartościowe sprzedaży / tankowania 

-- w aplikacji powinny byc zbierane dane kotnaktowe odbiorcow dostawcow oraz pracownikow
-- Wystawianie faktur dla klientow ktorzy dokonali zakupu


