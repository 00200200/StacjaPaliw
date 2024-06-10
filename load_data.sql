
-- Dostawcy
INSERT INTO Dostawcy (DostawcaID, Nazwa, Telefon, Email, Ulica, Miasto, KodPocztowy, Kraj)
VALUES (seq_DostawcaID.NEXTVAL, 'Dostawca A', '123456789', 'kontakt@dostawcaA.pl', 'Ulica A', 'Miasto A', '00-000', 'Polska');

INSERT INTO Dostawcy (DostawcaID, Nazwa, Telefon, Email, Ulica, Miasto, KodPocztowy, Kraj)
VALUES (seq_DostawcaID.NEXTVAL, 'Dostawca B', '987654321', 'kontakt@dostawcaB.pl', 'Ulica B', 'Miasto B', '11-111', 'Polska');

-- Paliwa4
INSERT INTO Paliwa (PaliwoID, RodzajPaliwa, CenaZaLitr, DostawcaID, AktualnyStan)
VALUES (seq_PaliwoID.NEXTVAL, 'Benzyna', 5.25, 1, 10000);

INSERT INTO Paliwa (PaliwoID, RodzajPaliwa, CenaZaLitr, DostawcaID, AktualnyStan)
VALUES (seq_PaliwoID.NEXTVAL, 'Diesel', 4.95, 1, 8000);

INSERT INTO Paliwa (PaliwoID, RodzajPaliwa, CenaZaLitr, DostawcaID, AktualnyStan)
VALUES (seq_PaliwoID.NEXTVAL, 'Benzyna', 5.15, 2, 9000);

INSERT INTO Paliwa (PaliwoID, RodzajPaliwa, CenaZaLitr, DostawcaID, AktualnyStan)
VALUES (seq_PaliwoID.NEXTVAL, 'Diesel', 4.85, 2, 8500);

-- Dystrybutory
INSERT INTO Dystrybutory (DystrybutorID, NumerDystrybutora, PaliwoID)
VALUES (seq_DystrybutorID.NEXTVAL, 1, 1);

INSERT INTO Dystrybutory (DystrybutorID, NumerDystrybutora, PaliwoID)
VALUES (seq_DystrybutorID.NEXTVAL, 2, 2);

INSERT INTO Dystrybutory (DystrybutorID, NumerDystrybutora, PaliwoID)
VALUES (seq_DystrybutorID.NEXTVAL, 3, 3);

INSERT INTO Dystrybutory (DystrybutorID, NumerDystrybutora, PaliwoID)
VALUES (seq_DystrybutorID.NEXTVAL, 4, 4);

-- KartyKredytowe
INSERT INTO KartyKredytowe (KartaKredytowaID, NumerKarty, DataWaznosci, KodBezpieczenstwa, Saldo)
VALUES (seq_KartaKredytowaID.NEXTVAL, '1234567812345678', '2025-12-31', '123', 0);

INSERT INTO Klienci (KlientID, Imie, Nazwisko, Telefon, Email, Ulica, Miasto, KodPocztowy, Kraj, KartaKredytowaID)
VALUES (seq_KlientID.NEXTVAL, 'Jan', 'Kowalski', '987654321', 'jan.kowalski@gmail.com', 'Ulica B', 'Miasto B', '11-111', 'Polska', seq_KartaKredytowaID.CURRVAL);

INSERT INTO KartyKredytowe (KartaKredytowaID, NumerKarty, DataWaznosci, KodBezpieczenstwa, Saldo)
VALUES (seq_KartaKredytowaID.NEXTVAL, '8765432187654321', '2026-06-30', '321', 0);

-- Klienci


INSERT INTO Klienci (KlientID, Imie, Nazwisko, Telefon, Email, Ulica, Miasto, KodPocztowy, Kraj, KartaKredytowaID)
VALUES (seq_KlientID.NEXTVAL, 'Anna', 'Nowak', '123456789', 'anna.nowak@gmail.com', 'Ulica A', 'Miasto A', '00-000', 'Polska', seq_KartaKredytowaID.CURRVAL);

-- Zmiany
INSERT INTO Zmiany (ZmianaID, RodzajZmiany, GodzinaRozpoczecia, GodzinaZakonczenia)
VALUES (seq_ZmianaID.NEXTVAL, 'Poranna', TO_TIMESTAMP('06:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('14:00:00', 'HH24:MI:SS'));

INSERT INTO Zmiany (ZmianaID, RodzajZmiany, GodzinaRozpoczecia, GodzinaZakonczenia)
VALUES (seq_ZmianaID.NEXTVAL, 'Popołudniowa', TO_TIMESTAMP('14:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('22:00:00', 'HH24:MI:SS'));

INSERT INTO Zmiany (ZmianaID, RodzajZmiany, GodzinaRozpoczecia, GodzinaZakonczenia)
VALUES (seq_ZmianaID.NEXTVAL, 'Nocna', TO_TIMESTAMP('22:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('06:00:00', 'HH24:MI:SS'));

-- Pracownicy (Kierownicy, Kasjerzy i Pracownicy Obsługi)
INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Kierownik1', 'Kowalski', 'Kierownik', '111111111', 'kierownik1@gmail.com', 'K1');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Kierownik2', 'Nowak', 'Kierownik', '222222222', 'kierownik2@gmail.com', 'K2');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Kierownik3', 'Wiśniewski', 'Kierownik', '333333333', 'kierownik3@gmail.com', 'K3');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Kasjer1', 'Zieliński', 'Kasjer', '444444444', 'kasjer1@gmail.com', 'C1');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Kasjer2', 'Wójcik', 'Kasjer', '555555555', 'kasjer2@gmail.com', 'C2');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Kasjer3', 'Kowalczyk', 'Kasjer', '666666666', 'kasjer3@gmail.com', 'C3');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Obsługa1', 'Majewski', 'Obsługa', '777777777', 'obsluga1@gmail.com', 'O1');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Obsługa2', 'Ostrowski', 'Obsługa', '888888888', 'obsluga2@gmail.com', 'O2');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Obsługa3', 'Król', 'Obsługa', '999999999', 'obsluga3@gmail.com', 'O3');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Obsługa4', 'Pawlak', 'Obsługa', '101010101', 'obsluga4@gmail.com', 'O4');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Obsługa5', 'Piotrowski', 'Obsługa', '111111111', 'obsluga5@gmail.com', 'O5');

INSERT INTO Pracownicy (PracownikID, Imie, Nazwisko, Stanowisko, Telefon, Email, IdentyfikatorElektroniczny)
VALUES (seq_PracownikID.NEXTVAL, 'Obsługa6', 'Sikorski', 'Obsługa', '121212121', 'obsluga6@gmail.com', 'O6');

-- PracownicyZmiany (Przypisanie pracowników do zmian)
-- Przypisanie Kierowników
INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 1, 1);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 2, 2);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 3, 3);

-- Przypisanie Kasjerów
INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 4, 1);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 5, 2);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 6, 3);

-- Przypisanie Pracowników Obsługi
INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 7, 1);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 8, 1);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 9, 2);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 10, 2);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 11, 3);

INSERT INTO PracownicyZmiany (PracownikZmianaID, PracownikID, ZmianaID)
VALUES (seq_PracownikZmianaID.NEXTVAL, 12, 3);


-- Transakcje
INSERT INTO Transakcje (TransakcjaID, Kwota, DataTransakcji, KartaKredytowaID, KasujacyID)
VALUES (seq_TransakcjaID.NEXTVAL, 157.5, TO_DATE('2023-06-01', 'YYYY-MM-DD'), 1, 1);

INSERT INTO Transakcje (TransakcjaID, Kwota, DataTransakcji, KartaKredytowaID, KasujacyID)
VALUES (seq_TransakcjaID.NEXTVAL, 200, TO_DATE('2023-06-01', 'YYYY-MM-DD'), 2, 2);

-- SzczegolyTransakcji
INSERT INTO SzczegolyTransakcji (SzczegolyTransakcjiID, TransakcjaID, PaliwoID, IloscPaliwa, Kwota, ObslugujacyID)
VALUES (seq_SzczegolyTransakcjiID.NEXTVAL, 1, 1, 30, 157.5, 7);

INSERT INTO SzczegolyTransakcji (SzczegolyTransakcjiID, TransakcjaID, PaliwoID, IloscPaliwa, Kwota, ObslugujacyID)
VALUES (seq_SzczegolyTransakcjiID.NEXTVAL, 2, 2,  40, 200, 8);


INSERT INTO PremiePracownikow (PracownikID, TransakcjaID, Punkty)
VALUES (7, 1, 150);

INSERT INTO PremiePracownikow (PracownikID, TransakcjaID, Punkty)
VALUES (8, 2, 200);