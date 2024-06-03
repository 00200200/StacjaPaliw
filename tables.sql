--TABELE-- 
CREATE TABLE Dostawcy (
    DostawcaID NUMBER DEFAULT SEQ_DOSTAWCAID.nextval PRIMARY KEY,
    Nazwa VARCHAR2(255) NOT NULL,
    Telefon VARCHAR2(15) NOT NULL,
    Email VARCHAR2(255) NOT NULL,
    Ulica VARCHAR2(255),
    Miasto VARCHAR2(255),
    KodPocztowy VARCHAR2(10),
    Kraj VARCHAR2(255)
);

CREATE TABLE Paliwa (
    PaliwoID NUMBER DEFAULT seq_PaliwoID.NEXTVAL PRIMARY KEY,
    RodzajPaliwa VARCHAR2(50) NOT NULL,
    CenaZaLitr NUMBER(3, 2) NOT NULL, -- Złotówki
    DostawcaID NUMBER NOT NULL,
    AktualnyStan NUMBER(10, 2) NOT NULL,
    FOREIGN KEY (DostawcaID) REFERENCES Dostawcy(DostawcaID)
);

CREATE TABLE Dystrybutory (
    DystrybutorID NUMBER DEFAULT seq_DystrybutorID.NEXTVAL PRIMARY KEY,
    NumerDystrybutora NUMBER NOT NULL,
    PaliwoID NUMBER NOT NULL,
    FOREIGN KEY (PaliwoID) REFERENCES Paliwa(PaliwoID)
);

CREATE TABLE KartyKredytowe (
    KartaKredytowaID NUMBER DEFAULT seq_KartaKredytowaID.NEXTVAL PRIMARY KEY,
    NumerKarty VARCHAR2(16) NOT NULL,
    DataWaznosci DATE NOT NULL,
    KodBezpieczenstwa VARCHAR2(3) NOT NULL,
    Saldo NUMBER(5, 2) DEFAULT 0
);

CREATE TABLE Klienci (
    KlientID NUMBER DEFAULT seq_KlientID.NEXTVAL PRIMARY KEY,
    Imie VARCHAR2(50) NOT NULL,
    Nazwisko VARCHAR2(50) NOT NULL,
    Telefon VARCHAR2(15) NOT NULL,
    Email VARCHAR2(255) NOT NULL,
    Ulica VARCHAR2(255),
    Miasto VARCHAR2(255),
    KodPocztowy VARCHAR2(10),
    Kraj VARCHAR2(50),
    KartaKredytowaID NUMBER,
    FOREIGN KEY (KartaKredytowaID) REFERENCES KartyKredytowe(KartaKredytowaID)
);

CREATE TABLE Pracownicy (
    PracownikID NUMBER DEFAULT seq_PracownikID.NEXTVAL PRIMARY KEY,
    Imie VARCHAR2(50) NOT NULL,
    Nazwisko VARCHAR2(50) NOT NULL,
    Stanowisko VARCHAR2(50) NOT NULL,
    Telefon VARCHAR2(15),
    Email VARCHAR2(255),
    IdentyfikatorElektroniczny VARCHAR2(50) NOT NULL
);

CREATE TABLE Transakcje (
    TransakcjaID NUMBER DEFAULT seq_TransakcjaID.NEXTVAL PRIMARY KEY,
    Kwota NUMBER(10, 2) NOT NULL,
    DataTransakcji DATE NOT NULL,
    KartaKredytowaID NUMBER NULL,
    KasujacyID NUMBER NOT NULL,
    FOREIGN KEY (KasujacyID) REFERENCES Pracownicy(PracownikID),
    FOREIGN KEY (KartaKredytowaID) REFERENCES KartyKredytowe(KartaKredytowaID)
);


CREATE TABLE SzczegolyTransakcji (
    SzczegolyTransakcjiID NUMBER DEFAULT seq_SzczegolyTransakcjiID.NEXTVAL PRIMARY KEY,
    TransakcjaID NUMBER NOT NULL,
    PaliwoID NUMBER NOT NULL,
    IloscPaliwa NUMBER(5, 2) NOT NULL,
    Kwota NUMBER(10, 2) NOT NULL,
    ObslugujacyID NUMBER NOT NULL,
  
    FOREIGN KEY (TransakcjaID) REFERENCES Transakcje(TransakcjaID),
    FOREIGN KEY (PaliwoID) REFERENCES Paliwa(PaliwoID),
    FOREIGN KEY (ObslugujacyID) REFERENCES Pracownicy(PracownikID)
);



CREATE TABLE Faktury (
    FakturaID NUMBER DEFAULT seq_FakturaID.NEXTVAL PRIMARY KEY,
    KlientID NUMBER NULL,
    TransakcjaID NUMBER NOT NULL,
    NIP VARCHAR2(10),
    FOREIGN KEY (KlientID) REFERENCES Klienci(KlientID),
    FOREIGN KEY (TransakcjaID) REFERENCES Transakcje(TransakcjaID)
);

CREATE TABLE Zamowienia (
    ZamowienieID NUMBER DEFAULT seq_ZamowienieID.NEXTVAL PRIMARY KEY,
    DataZamowienia DATE NOT NULL,
    Kwota NUMBER(10, 2) NOT NULL,
    Status VARCHAR2(20) DEFAULT 'Zamówione' CHECK (Status IN ('Zamówione', 'Przyjęte', 'Opłacone')),
    OdbiorcaID NUMBER,
    FOREIGN KEY (OdbiorcaID) REFERENCES Pracownicy(PracownikID)
);

CREATE TABLE SzczegolyZamowienia (
    SzczegolyZamowieniaID NUMBER DEFAULT seq_SzczegolyZamowieniaID.NEXTVAL PRIMARY KEY,
    ZamowienieID NUMBER NOT NULL,
    PaliwoID NUMBER NOT NULL,
    Ilosc NUMBER(10, 2) NOT NULL,
    CenaZaLitr NUMBER(3, 2) NOT NULL,
    FOREIGN KEY (ZamowienieID) REFERENCES Zamowienia(ZamowienieID),
    FOREIGN KEY (PaliwoID) REFERENCES Paliwa(PaliwoID)
);



CREATE TABLE Zmiany (
    ZmianaID NUMBER DEFAULT seq_ZmianaID.NEXTVAL PRIMARY KEY,
    RodzajZmiany VARCHAR2(50) NOT NULL,
    GodzinaRozpoczecia TIMESTAMP NOT NULL,
    GodzinaZakonczenia TIMESTAMP NOT NULL
);

CREATE TABLE PracownicyZmiany (
    PracownikZmianaID NUMBER DEFAULT seq_PracownikZmianaID.NEXTVAL PRIMARY KEY,
    PracownikID NUMBER NOT NULL,
    ZmianaID NUMBER NOT NULL,
    FOREIGN KEY (PracownikID) REFERENCES Pracownicy(PracownikID),
    FOREIGN KEY (ZmianaID) REFERENCES Zmiany(ZmianaID)
);

CREATE TABLE PremiePracownikow (
    PremiePracownikowID NUMBER DEFAULT seq_PremiePracownikowID.NEXTVAL PRIMARY KEY,
    PracownikID NUMBER NOT NULL,
    TransakcjaID NUMBER NOT NULL,
    Punkty NUMBER,
    FOREIGN KEY (PracownikID) REFERENCES Pracownicy(PracownikID),
    FOREIGN KEY (TransakcjaID) REFERENCES Transakcje(TransakcjaID)
);