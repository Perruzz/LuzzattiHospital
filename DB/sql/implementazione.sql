-- Eliminazione di entrambe le tabelle in caso esistano
DROP TABLE IF EXISTS utente CASCADE;
DROP TABLE IF EXISTS telefono CASCADE;
DROP TABLE IF EXISTS patologia CASCADE;
DROP TABLE IF EXISTS possesso CASCADE;
DROP TABLE IF EXISTS vaccino CASCADE;
DROP TABLE IF EXISTS eseguito CASCADE;
DROP TABLE IF EXISTS reparto CASCADE;
DROP TABLE IF EXISTS medico CASCADE;
DROP TABLE IF EXISTS infermiere CASCADE;
DROP TABLE IF EXISTS stanza CASCADE;
DROP TABLE IF EXISTS appuntamento CASCADE;
DROP TABLE IF EXISTS partecipazionemedico CASCADE;
DROP TABLE IF EXISTS partecipazioneinfermiere CASCADE;
DROP TABLE IF EXISTS referto CASCADE;
DROP TABLE IF EXISTS fattura CASCADE;

-- Creazione tabelle
CREATE TABLE utente (
       cf CHAR(16) PRIMARY KEY,
       nome VARCHAR(20) NOT NULL,
       cognome VARCHAR(20) NOT NULL,
       email VARCHAR(30) NOT NULL,
       nascita TIMESTAMP NOT NULL,
       totaledovuto MONEY NOT NULL,

       CHECK(totaledovuto::NUMERIC >= 0)
);

CREATE TABLE telefono (
       numero CHAR(10) PRIMARY KEY,
       utente CHAR(16) NOT NULL,

       FOREIGN KEY (utente) REFERENCES utente(cf) ON DELETE CASCADE
);

CREATE TABLE patologia (
       nome VARCHAR(30) PRIMARY KEY,
       descrizione VARCHAR(150) NOT NULL
);

CREATE TABLE possesso (
       patologia VARCHAR(30),
       utente CHAR(16),
       data TIMESTAMP NOT NULL,

       PRIMARY KEY (patologia, utente),
       FOREIGN KEY (patologia) REFERENCES patologia(nome) ON DELETE CASCADE,
       FOREIGN KEY (utente) REFERENCES utente(cf) ON DELETE CASCADE
);

CREATE TABLE vaccino (
       nome VARCHAR(30) PRIMARY KEY,
       descrizione VARCHAR(150) NOT NULL
);

CREATE TABLE eseguito (
       vaccino VARCHAR(30),
       utente CHAR(16),
       data TIMESTAMP NOT NULL,

       PRIMARY KEY (vaccino, utente),
       FOREIGN KEY (vaccino) REFERENCES vaccino(nome) ON DELETE CASCADE,
       FOREIGN KEY (utente) REFERENCES utente(cf) ON DELETE CASCADE
);

CREATE TABLE reparto(
       nome VARCHAR(20) PRIMARY KEY,
       descrizione VARCHAR(150) NOT NULL,
       primario INT -- La foreign key viene messa sotto con l'alter table, perchè prima devo creare medico
);

CREATE TABLE medico(
       id INT PRIMARY KEY,
       nome VARCHAR(20) NOT NULL,
       cognome VARCHAR(20) NOT NULL,
       nascita TIMESTAMP NOT NULL,
       specializzazione VARCHAR(20) NOT NULL,
       reparto VARCHAR(20),

       FOREIGN KEY (reparto) REFERENCES reparto(nome) ON DELETE NO ACTION
);

ALTER TABLE reparto
ADD FOREIGN KEY (primario) REFERENCES medico(id) DEFERRABLE; 

CREATE TABLE infermiere(
       id INT PRIMARY KEY,
       nome VARCHAR(20) NOT NULL,
       cognome VARCHAR(20) NOT NULL,
       nascita TIMESTAMP NOT NULL,
       reparto VARCHAR(20),

       FOREIGN KEY (reparto) REFERENCES reparto(nome) ON DELETE NO ACTION 
);

CREATE TABLE stanza(
       reparto VARCHAR(20),
       numero INT,
       posti INT NOT NULL,
       piano INT NOT NULL,

       PRIMARY KEY (reparto, numero),
       FOREIGN KEY (reparto) REFERENCES reparto(nome) ON DELETE NO ACTION,
       CHECK(posti > 0)
);

CREATE TABLE appuntamento(
       utente CHAR(16),
       data TIMESTAMP,
       reparto VARCHAR(20) NOT NULL,
       stanza INT NOT NULL,

       PRIMARY KEY (utente, data),
       FOREIGN KEY (utente) REFERENCES utente(cf) ON DELETE CASCADE,
       FOREIGN KEY (reparto, stanza) REFERENCES stanza(reparto, numero) ON DELETE NO ACTION,
       UNIQUE(data, stanza)
);

CREATE TABLE partecipazionemedico(
       medico INT,
       utente CHAR(16),
       data TIMESTAMP,

       PRIMARY KEY (medico, utente, data),
       FOREIGN KEY (medico) REFERENCES medico(id) ON DELETE NO ACTION,
       FOREIGN KEY (utente, data) REFERENCES appuntamento(utente, data) ON DELETE CASCADE
);


CREATE TABLE partecipazioneinfermiere(
       infermiere INT,
       utente CHAR(16),
       data TIMESTAMP,

       PRIMARY KEY (infermiere, utente, data),
       FOREIGN KEY (infermiere) REFERENCES infermiere(id) ON DELETE NO ACTION,
       FOREIGN KEY (utente, data) REFERENCES appuntamento(utente, data) ON DELETE CASCADE
);

CREATE TABLE referto(
       utente CHAR(16),
       data TIMESTAMP,
       esito VARCHAR(20) NOT NULL,
       emissione TIMESTAMP NOT NULL,

       PRIMARY KEY (utente, data),
       FOREIGN KEY (utente, data) REFERENCES appuntamento(utente, data) ON DELETE CASCADE,
       CHECK(emissione >= data)
);

CREATE TABLE fattura(
       utente CHAR(16),
       data TIMESTAMP,
       emissione TIMESTAMP NOT NULL,
       stato VARCHAR(20) NOT NULL,
       ammontare MONEY NOT NULL,

       PRIMARY KEY (utente, data),
       FOREIGN KEY (utente, data) REFERENCES appuntamento(utente, data) ON DELETE CASCADE,
       CHECK(emissione >= data)
);

-- Creazione indice su fattura(stato), usando un hash table
DROP INDEX IF EXISTS fstato;
CREATE INDEX fstato ON fattura USING hash (stato);

-- Inserimento Utenti
INSERT INTO utente VALUES 
('RSSMRA85M01H501Z', 'Cyrill', 'Shirer', 'cshirer0@elpais.com', '8/2/2005', 250),
('VNTGPP80A01F205K', 'Natka', 'Jeune', 'njeune1@wufoo.com', '3/24/1989', 0),
('PLNMNL70C01G273X', 'Carmella', 'Curley', 'ccurley2@devhub.com', '4/24/1981', 0),
('BRGLNE95E01H501D', 'Trula', 'Gherardelli', 'tgherardelli3@phoca.cz', '7/12/1982', 0),
('CLDLCU60D01L219Y', 'Kristien', 'Vassar', 'kvassar4@yellowbook.com', '9/19/1980', 0),
('GRNTNA75M01D612U', 'Celeste', 'Kincey', 'ckincey5@usnews.com', '4/21/1970', 150),
('TRRLSN90B01E801V', 'Reinaldo', 'MacCahee', 'rmaccahee6@walmart.com', '6/10/1960', 130),
('RBGFRC85T01C573F', 'Belle', 'Simeon', 'bsimeon7@va.gov', '4/23/2005', 0),
('LVGGNN55A01I839S', 'Bogey', 'Knewstub', 'bknewstub8@businesswire.com', '12/27/203', 70),
('DLMVTR80E01Z404H', 'Wynn', 'Housaman', 'whousaman9@linkedin.com', '9/12/1999', 60);

-- Inserimento numeri di telefono
INSERT INTO telefono VALUES 
('5374411780', 'RSSMRA85M01H501Z'),
('1645727645', 'VNTGPP80A01F205K'),
('5182716591', 'PLNMNL70C01G273X'),
('4021457771', 'BRGLNE95E01H501D'),
('4303095745', 'CLDLCU60D01L219Y'),
('8750035991', 'GRNTNA75M01D612U'),
('6592469854', 'TRRLSN90B01E801V'),
('2020660172', 'RBGFRC85T01C573F'),
('0171070402', 'LVGGNN55A01I839S'),
('6398472519', 'DLMVTR80E01Z404H'),
('1592469854', 'TRRLSN90B01E801V'),
('2592469854', 'TRRLSN90B01E801V'),
('3182716591', 'PLNMNL70C01G273X');

-- Inserimento Patologia
INSERT INTO patologia VALUES
('Arteriosclerosi', 'Indurimento e restringimento delle arterie, che riduce il flusso sanguigno.'),
('Diabete Mellito', 'Malattia cronica caratterizzata da alti livelli di zucchero nel sangue.'),
('Hypertensione Arteriosa', 'Pressione sanguigna cronicamente alta, aumenta il rischio di malattie cardiache.'),
('Infarto Miocardico Acuto', 'Blocco del flusso sanguigno al cuore, causando danni al muscolo cardiaco.'),
('Cancro Colorettale', 'Tumore maligno che si forma nel colon o nel retto.'),
('Demenza Alzheimer', 'Malattia neurodegenerativa che causa perdita di memoria e funzionalità cognitive.'),
('Fibromialgia', 'Sindrome caratterizzata da dolore muscolare diffuso e affaticamento.'),
('Artrite Reumatoide', 'Malattia autoimmune che causa infiammazione e dolore nelle articolazioni.'),
('Cancro al Seno Femminile', 'Tumore maligno che si forma nei tessuti del seno.'),
('Malattia di Parkinson', 'Disturbo neurodegenerativo che provoca tremori e rigidità muscolare.');

-- Inserimento Possesso
INSERT INTO possesso VALUES
('Arteriosclerosi', 'RSSMRA85M01H501Z', '2/4/1993'),
('Cancro al Seno Femminile', 'VNTGPP80A01F205K', '7/23/2007'),
('Artrite Reumatoide', 'RBGFRC85T01C573F', '9/24/1996'),
('Infarto Miocardico Acuto', 'RBGFRC85T01C573F', '6/13/1972'),
('Fibromialgia', 'GRNTNA75M01D612U', '3/28/2011'),
('Demenza Alzheimer', 'GRNTNA75M01D612U', '3/28/2020'),
('Demenza Alzheimer', 'RSSMRA85M01H501Z', '4/28/2022');

-- Inserimento Vaccino
INSERT INTO vaccino VALUES
('DTP', 'Vaccino che protegge contro difterite (infezione respiratoria), tetano (spasmi muscolari gravi) e pertosse (tosse convulsa).'),
('Polio', 'Vaccino che protegge contro la poliomielite, una malattia virale che può causare paralisi.'),
('MPR', 'Vaccino che protegge contro morbillo (rash e febbre), parotite (gonfiore delle ghiandole salivari) e rosolia (rash e febbre).'),
('Hib', 'Vaccino che protegge contro Haemophilus influenzae tipo B, che può causare meningite e infezioni gravi nei bambini.'),
('Epatite B', 'Vaccino che protegge contro l''epatite B, un virus che causa infezioni croniche del fegato.'),
('Meningococco', 'Vaccino che protegge contro Neisseria meningitidis, un batterio che può causare meningite e setticemia.'),
('Pneumococco', 'Vaccino che protegge contro Streptococcus pneumoniae, responsabile di polmonite, meningite e infezioni del sangue.'),
('Rotavirus', 'Vaccino che protegge contro il rotavirus, che causa gastroenterite acuta con diarrea e vomito nei bambini.'),
('HPV', 'Vaccino che protegge contro il papillomavirus umano, che può causare cancro cervicale e altre neoplasie.'),
('Influenza stagionale', 'Vaccino che protegge contro i ceppi del virus dell''influenza, riducendo il rischio di gravi complicanze.');

-- Inserimento Eseguito
INSERT INTO eseguito VALUES
('Influenza stagionale', 'CLDLCU60D01L219Y', '2/5/1993'),
('Rotavirus', 'CLDLCU60D01L219Y', '2/10/2006'),
('Epatite B', 'LVGGNN55A01I839S', '9/24/1999'),
('Polio', 'RBGFRC85T01C573F', '6/13/1978'),
('DTP', 'DLMVTR80E01Z404H', '3/28/2010');

BEGIN;
SET CONSTRAINTS ALL DEFERRED;

    -- Inserimento Reparto
    INSERT INTO reparto VALUES
    ('Cardiologia', 'Si occupa della diagnosi e del trattamento delle malattie cardiovascolari, inclusi problemi del cuore e dei vasi sanguigni.', 1),
    ('Neurologia', 'Tratta le malattie del sistema nervoso, compresi il cervello, il midollo spinale e i nervi periferici.', 2),
    ('Oncologia', 'Si dedica alla diagnosi, al trattamento e alla ricerca sul cancro e altre neoplasie.', 3),
    ('Pediatria', 'Fornisce cure mediche ai bambini e agli adolescenti, seguendo la crescita e lo sviluppo fisico e psicologico.', 4),
    ('Ortopedia', 'Si occupa delle malattie e delle lesioni dell''apparato muscolo-scheletrico, inclusi ossa, articolazioni, muscoli, tendini e legamenti.', NULL);

    -- Inserimento Medico
    INSERT INTO medico VALUES
    (1, 'Orland', 'Capelin', '12/2/1992', 'Cardiologo', 'Cardiologia'),
    (2, 'Johnnie', 'Ryal', '9/5/1999', 'Neurologo', 'Neurologia'),
    (3, 'Crysta', 'Giovannoni', '12/17/1985', 'Oncologo', 'Oncologia'),
    (4, 'Dasi', 'Blundan', '7/28/1979', 'Pediatra', 'Pediatria'),
    (5, 'Babs', 'Buche', '3/6/1988', 'Ortopedico', 'Ortopedia'),
    (6, 'Emerson', 'Vasyutochkin', '10/22/1994', 'Dermatologo', 'Pediatria'),
    (7, 'Harley', 'Sommerlin', '3/10/1999', 'Endocrinologo', 'Pediatria'),
    (8, 'Alford', 'Shillaker', '3/3/1971', 'Gastroenterologo', NULL),
    (9, 'Lory', 'Magowan', '5/10/1987', 'Ginecologo', NULL),
    (10, 'Cammy', 'Houdmont', '2/19/1981', 'Psichiatra', 'Neurologia');

COMMIT;

-- Inserimento Infermiere
INSERT INTO infermiere VALUES
(1, 'Corrie', 'Millins', '5/25/1991', 'Cardiologia'),
(2, 'Odella', 'Walhedd', '10/9/1988', 'Neurologia'),
(3, 'Guillermo', 'Chotty', '5/13/1993', 'Oncologia'),
(4, 'Elfreda', 'Oxtoby', '12/12/1993', 'Pediatria'),
(5, 'Albert', 'Wickey', '9/28/1979', 'Ortopedia'),
(6, 'Caryl', 'Coetzee', '12/30/2002', 'Cardiologia'),
(7, 'Horatio', 'Shenfisch', '10/12/1979', 'Neurologia'),
(8, 'Bentley', 'Ellerby', '11/19/1996', 'Oncologia'),
(9, 'Lilah', 'Courtes', '1/15/1979', 'Pediatria'),
(10, 'Andromache', 'Cymper', '10/24/1976', NULL);

-- Inserimento Stanza
INSERT INTO stanza VALUES
('Cardiologia', 1, 4, 1),
('Neurologia', 1, 2, 1),
('Oncologia', 1, 1, 2),
('Pediatria', 1, 6, 2),
('Ortopedia', 1, 7, 1),
('Cardiologia', 2, 2, 2),
('Neurologia', 2, 3, 1),
('Oncologia', 2, 4, 2),
('Pediatria', 2, 2, 3),
('Ortopedia', 2, 1, 3),
('Cardiologia', 3, 3, 2),
('Cardiologia', 4, 4, 2);

-- Inserimento Appuntamento
INSERT INTO appuntamento VALUES
('RSSMRA85M01H501Z', '2020-09-22 14:17', 'Cardiologia', 1),
('BRGLNE95E01H501D', '2020-05-26 22:20', 'Oncologia', 1),
('CLDLCU60D01L219Y', '2021-12-21 01:27', 'Ortopedia', 1),
('TRRLSN90B01E801V', '2022-04-22 20:27', 'Oncologia', 2),
('RSSMRA85M01H501Z', '2023-05-25 20:39', 'Ortopedia', 2),
('RSSMRA85M01H501Z', '2023-03-25 00:34', 'Ortopedia', 2),
('RBGFRC85T01C573F', '2023-10-25 09:11', 'Cardiologia', 2),
('LVGGNN55A01I839S', '2022-11-02 04:28', 'Cardiologia', 1),
('LVGGNN55A01I839S', '2020-06-01 12:42', 'Neurologia', 1),
('DLMVTR80E01Z404H', '2023-07-23 07:56', 'Oncologia', 2),
('GRNTNA75M01D612U', '2020-01-20 08:00', 'Neurologia', 2),
('GRNTNA75M01D612U', '2021-01-20 08:00', 'Neurologia', 2);

-- Inserimento PartecipazioneMedico
INSERT INTO partecipazionemedico VALUES
(1, 'RSSMRA85M01H501Z', '2020-09-22 14:17'),
(1, 'BRGLNE95E01H501D', '2020-05-26 22:20'),
(2, 'RSSMRA85M01H501Z', '2020-09-22 14:17'),
(3, 'BRGLNE95E01H501D', '2020-05-26 22:20'),
(3, 'CLDLCU60D01L219Y', '2021-12-21 01:27'),
(2, 'TRRLSN90B01E801V', '2022-04-22 20:27'),
(4, 'TRRLSN90B01E801V', '2022-04-22 20:27'),
(5, 'RSSMRA85M01H501Z', '2023-05-25 20:39'),
(5, 'RSSMRA85M01H501Z', '2023-03-25 00:34'),
(5, 'LVGGNN55A01I839S', '2022-11-02 04:28'),
(9, 'LVGGNN55A01I839S', '2022-11-02 04:28'),
(9, 'DLMVTR80E01Z404H', '2023-07-23 07:56'),
(8, 'LVGGNN55A01I839S', '2020-06-01 12:42'),
(8, 'DLMVTR80E01Z404H', '2023-07-23 07:56');

-- Inserimento PartecipazioneInfermiere
INSERT INTO partecipazioneinfermiere VALUES
(1, 'RSSMRA85M01H501Z', '2020-09-22 14:17'),
(2, 'BRGLNE95E01H501D', '2020-05-26 22:20'),
(3, 'CLDLCU60D01L219Y', '2021-12-21 01:27'),
(7, 'TRRLSN90B01E801V', '2022-04-22 20:27'),
(6, 'RSSMRA85M01H501Z', '2023-05-25 20:39'),
(6, 'LVGGNN55A01I839S', '2022-11-02 04:28'),
(8, 'LVGGNN55A01I839S', '2020-06-01 12:42'),
(10, 'DLMVTR80E01Z404H', '2023-07-23 07:56');

-- Inserimento Referto
INSERT INTO referto VALUES
('RSSMRA85M01H501Z', '2020-09-22 14:17', 'Positivo', '2020-10-22 14:17'),
('BRGLNE95E01H501D', '2020-05-26 22:20', 'Positivo', '2020-06-26 22:20'),
('CLDLCU60D01L219Y', '2021-12-21 01:27', 'Incerto', '2021-12-30 01:27'),
('TRRLSN90B01E801V', '2022-04-22 20:27', 'Negativo', '2022-05-22 20:27'),
('RBGFRC85T01C573F', '2023-10-25 09:11', 'Incerto', '2023-11-25 09:11'),
('LVGGNN55A01I839S', '2022-11-02 04:28', 'Negativo', '2022-12-02 04:28'),
('LVGGNN55A01I839S', '2020-06-01 12:42', 'Negativo', '2020-07-01 12:42');

-- Inserimento Fattura
INSERT INTO fattura VALUES
('RSSMRA85M01H501Z', '2020-09-22 14:17', '2020-10-22 14:17', 'Da pagare', 100),
('CLDLCU60D01L219Y', '2021-12-21 01:27', '2021-12-29 01:27', 'Pagato', 120),
('TRRLSN90B01E801V', '2022-04-22 20:27', '2022-05-22 20:27', 'Da pagare', 130),
('RSSMRA85M01H501Z', '2023-05-25 20:39', '2023-06-25 20:39', 'Da pagare', 150),
('RSSMRA85M01H501Z', '2023-03-25 00:34', '2023-05-25 00:34', 'Pagato', 90),
('LVGGNN55A01I839S', '2022-11-02 04:28', '2022-12-02 04:28', 'Pagato', 50),
('LVGGNN55A01I839S', '2020-06-01 12:42', '2020-06-10 12:42', 'Da pagare', 70),
('DLMVTR80E01Z404H', '2023-07-23 07:56', '2023-07-30 07:56', 'Da pagare', 60),
('GRNTNA75M01D612U', '2020-01-20 08:00', '2020-04-30 00:00', 'Da pagare', 100),
('GRNTNA75M01D612U', '2021-01-20 08:00', '2021-04-30 00:00', 'Da pagare', 50);

-- Creazione views per le query
DROP VIEW IF EXISTS ammontare_reparto;
DROP VIEW IF EXISTS medico_primario;

-- Per ogni medico primario dare il numero di appuntamenti in cui ha partecipato
CREATE VIEW medico_primario AS
SELECT id
FROM medico, reparto
WHERE medico.id = reparto.primario;

SELECT medico.id, nome, cognome, n_appuntamenti
FROM medico, (SELECT medico_primario.id, COUNT(*) n_appuntamenti
              FROM partecipazionemedico pm, medico_primario
              WHERE pm.medico = medico_primario.id
              GROUP BY medico_primario.id) med_p
WHERE medico.id = med_p.id;

-- Numero di stanze in ogni reparto che possiede un primario

SELECT nome, COUNT(*) n_stanze
FROM reparto, stanza
WHERE reparto.nome = stanza.reparto
      AND reparto.primario IS NOT NULL
GROUP BY nome;

-- Per ogni reparto elencare il totale fatturato

CREATE VIEW ammontare_reparto AS
SELECT stanza.reparto AS rep, SUM(fattura.ammontare) AS tot
FROM stanza, appuntamento, fattura
WHERE appuntamento.reparto = stanza.reparto
    AND appuntamento.stanza = stanza.numero
    AND fattura.utente = appuntamento.utente
    AND fattura.data = appuntamento.data
GROUP BY stanza.reparto;

SELECT * FROM ammontare_reparto
UNION
SELECT reparto.nome AS rep, CAST(0 AS money) AS tot
FROM reparto
WHERE reparto.nome NOT IN (SELECT rep FROM ammontare_reparto)
ORDER BY tot DESC;

-- Per ogni vaccino indicare il numero di utenti nati prima del 1990 che l'ha effettuato

SELECT vaccino.nome, count(cf)
FROM (vaccino LEFT JOIN eseguito ON vaccino.nome = eseguito.vaccino)
     LEFT JOIN (SELECT cf FROM utente WHERE nascita < '1990-01-01') utente ON utente.cf = eseguito.utente
GROUP BY vaccino.nome;

-- Tutti gli utenti che soffrono di 'Demenza Alzheimer' con almeno due fatture da pagare

SELECT appuntamento.utente
FROM appuntamento, fattura,
     (SELECT utente FROM possesso WHERE patologia = 'Demenza Alzheimer') utente_alzheimer
WHERE appuntamento.data = fattura.data AND appuntamento.utente = fattura.utente
      AND utente_alzheimer.utente = appuntamento.utente AND fattura.stato = 'Da pagare'
GROUP BY appuntamento.utente
HAVING COUNT(fattura.utente) >= 2;
