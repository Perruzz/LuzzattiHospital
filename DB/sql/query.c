#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>

#define DB_NAME "postgres"
#define DB_USER "postgres"
#define DB_PASS "postgres"
#define DB_HOST "localhost"
#define DB_PORT 5432

#define size(arr) sizeof(arr)/sizeof(arr[0])

void exec_and_print_query(PGconn* conn, const char* query[], const char* query_description[], size_t query_size);

int main(int argc, char* argv[]) {

    const char* query[] = {
        "SELECT medico.id, nome, cognome, n_appuntamenti FROM medico, (SELECT medico_primario.id, COUNT(*) n_appuntamenti FROM partecipazionemedico pm, medico_primario WHERE pm.medico = medico_primario.id GROUP BY medico_primario.id) med_p WHERE medico.id = med_p.id",
        "SELECT nome, COUNT(*) n_stanze FROM reparto, stanza WHERE reparto.nome = stanza.reparto AND reparto.primario IS NOT NULL GROUP BY nome",
        "SELECT * FROM ammontare_reparto UNION SELECT reparto.nome AS rep, CAST(0 AS money) AS tot FROM reparto WHERE reparto.nome NOT IN (SELECT rep FROM ammontare_reparto) ORDER BY tot DESC",
        "SELECT vaccino.nome, count(cf) FROM (vaccino LEFT JOIN eseguito ON vaccino.nome = eseguito.vaccino) LEFT JOIN (SELECT cf FROM utente WHERE nascita < '1990-01-01') utente ON utente.cf = eseguito.utente GROUP BY vaccino.nome",
        "SELECT appuntamento.utente FROM appuntamento, fattura, (SELECT utente FROM possesso WHERE patologia = 'Demenza Alzheimer') utente_alzheimer WHERE appuntamento.data = fattura.data AND appuntamento.utente = fattura.utente AND utente_alzheimer.utente = appuntamento.utente AND fattura.stato = 'Da pagare' GROUP BY appuntamento.utente HAVING COUNT(fattura.utente) >= 2"
    };
    
    const char* query_description[] = {
        "Per ogni medico primario dare il numero di appuntamenti in cui ha partecipato",
        "Numero di stanze in ogni reparto che possiede un primario",
        "Per ogni reparto elencare il totale fatturato",
        "Per ogni vaccino indicare il numero di utenti nati prima del 1990 che l'ha effettuato",
        "Tutti gli utenti che soffrono di 'Demenza Alzheimer' con almeno due fatture da pagare"
    };

    // Ogni query deve essere associata ad una descrizione
    if (size(query) != size(query_description)) {
        fprintf(stderr, "ERROR: size(query) != size(query_description)");
        exit(1);
    }

    // Posso passare come parametro il numero della query che mi interessa, altrimenti le stampo tutte
    if (argc > 2) {
        fprintf(stderr, "Usage: ./query [1-%ld]\n", size(query));
        exit(1);
    }

    size_t query_n = 0;
    if (argc == 2) {
        query_n = atoi(argv[1]);
        if (!(query_n >= 1 && query_n <= size(query))) {
            fprintf(stderr, "Enter a number between 1 and %ld!\n", size(query));
            exit(1);
        }
    }

    char conninfo[200];
    sprintf(conninfo, "dbname=%s user=%s password=%s host=%s port=%d", DB_NAME, DB_USER, DB_PASS, DB_HOST, DB_PORT);
    PGconn *conn = PQconnectdb(conninfo);

    if (PQstatus(conn) == CONNECTION_BAD) {
        fprintf(stderr, "Connection to db failed: %s", PQerrorMessage(conn));
        PQfinish(conn);
        exit(1);
    }

    if (query_n >= 1 && query_n <= size(query))
        exec_and_print_query(conn, (const char*[]) {query[query_n-1]}, (const char*[]) {query_description[query_n-1]}, 1);
    else
        exec_and_print_query(conn, query, query_description, size(query));

    PQfinish(conn);
    return 0;
}

// Eseguo e stampo le query con le relative descrizioni
void exec_and_print_query(PGconn* conn, const char* query[], const char* query_description[], size_t query_size) {

    PQprintOpt options = {0};
    options.header = 1;
    options.align = 1;
    options.fieldSep = "|";

    printf("\n");

    for(size_t i = 0; i < query_size; ++i) {
        PGresult *res = PQexec(conn, query[i]); 

        if (PQresultStatus(res) != PGRES_TUPLES_OK) {
            fprintf(stderr, "No results found: %s", PQerrorMessage(conn));
            PQclear(res);
            PQfinish(conn);
            exit(1);
        }

        printf("%s:\n", query_description[i]);
        PQprint(stdout, res, &options);
        PQclear(res);
    }
}
