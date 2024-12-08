//Pacote PKG_ALUNO

CREATE OR REPLACE PACKAGE PKG_ALUNO AS
  PROCEDURE excluir_aluno(p_id_aluno NUMBER);
  CURSOR listar_maiores_de_18 IS
    SELECT nome, data_nascimento
    FROM alunos
    WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12) > 18;
  FUNCTION alunos_por_curso(p_id_curso NUMBER) RETURN SYS_REFCURSOR;
END PKG_ALUNO;

CREATE OR REPLACE PACKAGE BODY PKG_ALUNO AS
  PROCEDURE excluir_aluno(p_id_aluno NUMBER) IS
  BEGIN
    DELETE FROM matriculas WHERE id_aluno = p_id_aluno;
    DELETE FROM alunos WHERE id_aluno = p_id_aluno;
  END excluir_aluno;

  FUNCTION alunos_por_curso(p_id_curso NUMBER) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
  BEGIN
    OPEN v_cursor FOR
      SELECT nome
      FROM alunos a
      JOIN matriculas b ON a.id_aluno = b.id_aluno
      WHERE b.id_curso = p_id_curso;
    RETURN v_cursor;
  END alunos_por_curso;
END PKG_ALUNO;

//Pacote PKG_DISCIPLINA

CREATE OR REPLACE PACKAGE PKG_DISCIPLINA AS
  PROCEDURE cadastrar(p_nome VARCHAR2, p_descricao VARCHAR2, p_carga NUMBER);
  CURSOR total_alunos_disciplina IS
    SELECT c.nome, COUNT(m.id_aluno) AS total_alunos
    FROM disciplinas c
    JOIN matriculas b ON d.id_disciplina = b.id_disciplina
    GROUP BY c.nome
    HAVING COUNT(m.id_aluno) > 10;
  FUNCTION media_idade_disciplina(p_id_disciplina NUMBER) RETURN NUMBER;
  PROCEDURE listar_alunos_disciplina(p_id_disciplina NUMBER);
END PKG_DISCIPLINA;

CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA AS
  PROCEDURE cadastrar(p_nome VARCHAR2, p_descricao VARCHAR2, p_carga NUMBER) IS
  BEGIN
    INSERT INTO disciplinas (nome, descricao, carga)
    VALUES (p_nome, p_descricao, p_carga);
  END cadastrar;

  FUNCTION media_idade_disciplina(p_id_disciplina NUMBER) RETURN NUMBER IS
    v_media NUMBER;
  BEGIN
    SELECT AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12))
    INTO v_media
    FROM alunos a
    JOIN matriculas b ON a.id_aluno = b.id_aluno
    WHERE b.id_disciplina = p_id_disciplina;
    RETURN v_media;
  END media_idade_disciplina;

  PROCEDURE listar_alunos_disciplina(p_id_disciplina NUMBER) IS
  BEGIN
    FOR r IN (SELECT a.nome
              FROM alunos a
              JOIN matriculas b ON a.id_aluno = b.id_aluno
              WHERE b.id_disciplina = p_id_disciplina) LOOP
      DBMS_OUTPUT.PUT_LINE(r.nome);
    END LOOP;
  END listar_alunos_disciplina;
END PKG_DISCIPLINA;

//Pacote PKG_PROFESSOR

CREATE OR REPLACE PACKAGE PKG_PROFESSOR AS
  CURSOR total_turmas_professor IS
    SELECT d.nome, COUNT(e.id_turma) AS total_turmas
    FROM professores d
    JOIN turmas e ON d.id_professor = e.id_professor
    GROUP BY d.nome
    HAVING COUNT(e.id_turma) > 1;
  FUNCTION total_turmas_professor(p_id_professor NUMBER) RETURN NUMBER;
  FUNCTION professor_disciplina(p_id_disciplina NUMBER) RETURN VARCHAR2;
END PKG_PROFESSOR;

CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR AS
  FUNCTION total_turmas_professor(p_id_professor NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(e.id_turma)
    INTO v_total
    FROM turmas e
    WHERE e.id_professor = p_id_professor;
    RETURN v_total;
  END total_turmas_professor;

  FUNCTION professor_disciplina(p_id_disciplina NUMBER) RETURN VARCHAR2 IS
    v_nome_professor VARCHAR2(100);
  BEGIN
    SELECT d.nome
    INTO v_nome_professor
    FROM professores d
    JOIN disciplinas c ON d.id_professor = c.id_professor
    WHERE c.id_disciplina = p_id_disciplina;
    RETURN v_nome_professor;
  END professor_disciplina;
END PKG_PROFESSOR;