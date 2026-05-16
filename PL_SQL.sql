SET SERVEROUTPUT ON;

--zadanie 1

DECLARE
    v_liczba_kursantow NUMBER;
    v_liczba_kursow    NUMBER;
    v_liczba_wykladowcow NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_liczba_kursantow FROM kursanci;
    SELECT COUNT(*) INTO v_liczba_kursow FROM kursy;
    SELECT COUNT(*) INTO v_liczba_wykladowcow FROM wykladowcy;
    
    DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || v_liczba_kursantow);
    DBMS_OUTPUT.PUT_LINE('Liczba kursów: ' || v_liczba_kursow);
    DBMS_OUTPUT.PUT_LINE('Liczba wykładowców: ' || v_liczba_wykladowcow);
END;
--zadanie 2

DECLARE
    v_suma_wartosci NUMBER;
BEGIN
    SELECT SUM(r.cena)
    INTO v_suma_wartosci
    FROM umowy u
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';

    DBMS_OUTPUT.PUT_LINE('Łaczna wartosć umów dla BYDGOSZCZY: ' || v_suma_wartosci || ' zł');
END;

--Zadanie 3

DECLARE
    v_miasto      VARCHAR2(20) := 'BYDGOSZCZ';
    v_liczba_umow NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_liczba_umow 
    FROM umowy 
    WHERE miasto = v_miasto;

    IF v_liczba_umow = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak umów dla miasta ' || v_miasto);
    ELSIF v_liczba_umow < 50 THEN
        DBMS_OUTPUT.PUT_LINE('Mała liczba umów dla miasta ' || v_miasto);
    ELSIF v_liczba_umow <= 100 THEN
        DBMS_OUTPUT.PUT_LINE('srednia liczba umów dla miasta ' || v_miasto);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Duza liczba umów dla miasta ' || v_miasto);
    END IF;
END;

--zadanie 4

BEGIN
    FOR r IN (
        SELECT k.kurs_id, ro.nazwa, ro.godz, ro.cena, w.imie, w.nazwisko
        FROM kursy k
        JOIN rodzaje ro ON k.rodzaj_id = ro.rodzaj_id
        JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Kurs ' || r.kurs_id || ': ' || r.nazwa || ', ' || r.godz || 'h, ' || r.cena || ' zł, prowadzacy: ' || r.imie || ' ' || r.nazwisko);
    END LOOP;
END;


--zadanie 5
CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2) IS
    v_liczba  NUMBER;
    v_suma    NUMBER;
    v_srednia NUMBER;
BEGIN
    SELECT 
        COUNT(*), 
        NVL(SUM(r.cena), 0), 
        NVL(AVG(r.cena), 0)
    INTO v_liczba, v_suma, v_srednia
    FROM umowy u
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = p_miasto;

    DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || p_miasto);
    DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba);
    DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_suma || ' zł');
    DBMS_OUTPUT.PUT_LINE('Średnia wartość umowy: ' || ROUND(v_srednia, 2) || ' zł');
END;
/

-- Uruchomienie procedury:
BEGIN
  raport_umow_miasto('BYDGOSZCZ');
END;
/
--zadanie 6

CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER) RETURN NUMBER IS
    v_cena NUMBER;
BEGIN
    SELECT r.cena INTO v_cena
    FROM kursy k
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE k.kurs_id = p_kurs_id;

    RETURN v_cena;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; 
END;
/

--Test:
DECLARE
  v_cena NUMBER;
BEGIN
  v_cena := wartosc_kursu(1);
  DBMS_OUTPUT.PUT_LINE('Cena kursu 1: ' || v_cena);
  v_cena := wartosc_kursu(999); 
  DBMS_OUTPUT.PUT_LINE('Cena kursu 999: ' || v_cena);
END;
/
