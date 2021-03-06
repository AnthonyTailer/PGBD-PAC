USE reclamacoes_consumidor;

-- TRUNCATE RECLAMACAO;
-- TRUNCATE PROBLEMA;
-- TRUNCATE GRUPO;
-- TRUNCATE AREA;
-- TRUNCATE EMPRESA;
-- TRUNCATE SEGMENTO;
-- TRUNCATE CONSUMIDOR;
-- TRUNCATE CIDADE;
-- TRUNCATE ESTADO;
-- TRUNCATE REGIAO;
-- TRUNCATE RECLAMACAO_DES;

INSERT INTO REGIAO (NOME) SELECT DISTINCT REGIAO FROM RECLAMACAO_DES ORDER BY 1 ASC;

  INSERT INTO ESTADO (NOME, IDREGIAO)
    SELECT DISTINCT UF, IDREGIAO FROM RECLAMACAO_DES RD JOIN REGIAO R ON RD.REGIAO = R.NOME ORDER BY 1 ASC;

  INSERT INTO CIDADE (NOME, IDESTADO)
    SELECT DISTINCT CIDADE, IDESTADO FROM RECLAMACAO_DES RD JOIN ESTADO E ON RD.UF = E.NOME ORDER BY 1 ASC;

  INSERT INTO CONSUMIDOR (SEXO, FAIXAETARIA, IDCIDADE)
    SELECT DISTINCT SEXO, FAIXAETARIA, IDCIDADE FROM RECLAMACAO_DES RD
      JOIN CIDADE C ON RD.CIDADE = C.NOME JOIN ESTADO E ON C.IDESTADO = E.IDESTADO
      WHERE RD.UF = E.NOME;

      /* Criar coluna na tabela desnormalizada que referencia consumidor, para utilizar
 * nos JOINs da normalização. Realizar esse processo logo após popular a tabela CONSUMIDOR.
 */
ALTER TABLE RECLAMACAO_DES ADD COLUMN IDCONSUMIDOR INT;
UPDATE RECLAMACAO_DES RD SET IDCONSUMIDOR = (SELECT IDCONSUMIDOR FROM CONSUMIDOR CO NATURAL JOIN CIDADE CI
                                             WHERE CO.SEXO = RD.SEXO AND CO.FAIXAETARIA = RD.FAIXAETARIA
                                             AND CI.NOME = RD.CIDADE);

INSERT INTO SEGMENTO (DESCRICAO) SELECT DISTINCT SEGMENTOMERCADO FROM RECLAMACAO_DES ORDER BY 1 ASC;

  INSERT INTO EMPRESA (NOMEFANTASIA, IDSEGMENTO)
            SELECT DISTINCT NOMEFANTASIA, S.IDSEGMENTO FROM RECLAMACAO_DES RD JOIN SEGMENTO S ON RD.SEGMENTOMERCADO = S.DESCRICAO
            ORDER BY 1 ASC;
      ALTER TABLE RECLAMACAO_DES ADD COLUMN IDEMPRESA INT;
      UPDATE RECLAMACAO_DES RD SET IDEMPRESA = (SELECT IDEMPRESA FROM EMPRESA E NATURAL JOIN SEGMENTO S
                WHERE E.NOMEFANTASIA = RD.NOMEFANTASIA AND S.DESCRICAO = RD.SEGMENTOMERCADO);

INSERT INTO AREA (DESCRICAO)
  SELECT DISTINCT AREA FROM RECLAMACAO_DES RD ORDER BY 1 ASC;

INSERT INTO GRUPO (DESCRICAO) SELECT DISTINCT GRUPOPROBLEMA FROM RECLAMACAO_DES RD ORDER BY 1 ASC;

  INSERT INTO PROBLEMA (DESCRICAO, IDGRUPO)
    SELECT DISTINCT PROBLEMA, IDGRUPO FROM RECLAMACAO_DES RD JOIN GRUPO G ON RD.GRUPOPROBLEMA = G.DESCRICAO ORDER BY 1 ASC;

  INSERT INTO RECLAMACAO (IDCONSUMIDOR, ANO, MES, DATAABERTURA, DATARESPOSTA, DATAFINALIZACAO,
        TEMPORESPOSTA, IDEMPRESA, IDAREA, ASSUNTO, IDPROBLEMA, COMOCOMPROU, PROCUROUEMPRESA, RESPONDIDA,
        SITUACAO, AVALIACAO, NOTACONSUMIDOR)
        SELECT IDCONSUMIDOR, ANOABERTURA, MESABERTURA, DATAABERTURA, DATARESPOSTA, DATAFINALIZACAO,
        TEMPORESPOSTA, IDEMPRESA, A.IDAREA, ASSUNTO, P.IDPROBLEMA, COMOCOMPROU, PROCUROUEMPRESA, RESPONDIDA,
        SITUACAO, AVALIACAO, NOTACONSUMIDOR
           FROM RECLAMACAO_DES RD
           JOIN AREA A ON RD.AREA = A.DESCRICAO
           JOIN PROBLEMA P ON RD.PROBLEMA = P.DESCRICAO;


/* Executar após popular a tabela RECLAMACAO */
ALTER TABLE RECLAMACAO_DES DROP COLUMN IDCONSUMIDOR;
ALTER TABLE RECLAMACAO_DES DROP COLUMN IDEMPRESA;
