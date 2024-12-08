# Lista-de-exerc-cio-Packages

Este repositório contém o código de três pacotes PL/SQL utilizados para gerenciamento acadêmico de alunos, disciplinas e professores em um sistema educacional. O código foi desenvolvido para interagir com um banco de dados Oracle.

Pacotes Disponíveis
1. PKG_ALUNO
Este pacote gerencia operações relacionadas aos alunos no sistema, como exclusão de aluno e listagem de alunos maiores de 18 anos.

Procedures
excluir_aluno(p_id_aluno NUMBER): Exclui um aluno do banco de dados, removendo primeiro as matrículas associadas.
Cursors
listar_maiores_de_18: Retorna uma lista de alunos maiores de 18 anos com seus nomes e datas de nascimento.
Functions
alunos_por_curso(p_id_curso NUMBER) RETURN SYS_REFCURSOR: Retorna um cursor com os nomes dos alunos matriculados em um determinado curso.

2. PKG_DISCIPLINA
Este pacote contém funcionalidades para gerenciar disciplinas, incluindo cadastro, cálculo da média de idades dos alunos em uma disciplina e listagem dos alunos matriculados.

Procedures
cadastrar(p_nome VARCHAR2, p_descricao VARCHAR2, p_carga NUMBER): Cadastra uma nova disciplina no sistema.
listar_alunos_disciplina(p_id_disciplina NUMBER): Exibe os alunos matriculados em uma disciplina específica no console.
Cursors
total_alunos_disciplina: Retorna o nome das disciplinas com mais de 10 alunos matriculados e a quantidade de alunos.
Functions
media_idade_disciplina(p_id_disciplina NUMBER) RETURN NUMBER: Retorna a média das idades dos alunos matriculados em uma disciplina.

3. PKG_PROFESSOR
Este pacote gerencia as informações relacionadas aos professores, incluindo o número de turmas e disciplinas em que eles estão envolvidos.

Functions
total_turmas_professor(p_id_professor NUMBER) RETURN NUMBER: Retorna o número de turmas associadas a um professor específico.
professor_disciplina(p_id_disciplina NUMBER) RETURN VARCHAR2: Retorna o nome do professor que leciona uma determinada disciplina.
Cursors
total_turmas_professor: Retorna o nome dos professores com mais de uma turma associada e o total de turmas.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Como Utilizar
1. Criação dos Pacotes
Execute os seguintes scripts para criar os pacotes no banco de dados Oracle (Exemplo utilizando PKG_ALUNO).

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

Repita o mesmo processo para os pacotes PKG_DISCIPLINA e PKG_PROFESSOR.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2. Exemplo de Uso
Para listar os alunos maiores de 18 anos:

DECLARE
  v_nome VARCHAR2(100);
  v_data_nascimento DATE;
BEGIN
  FOR r IN PKG_ALUNO.listar_maiores_de_18 LOOP
    v_nome := r.nome;
    v_data_nascimento := r.data_nascimento;
    DBMS_OUTPUT.PUT_LINE(v_nome || ' - ' || v_data_nascimento);
  END LOOP;
END;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3. Dependências
Este código depende de tabelas previamente existentes no banco de dados:

alunos: Tabela com informações dos alunos (id_aluno, nome, data_nascimento, etc.).
matriculas: Tabela que associa alunos a cursos e disciplinas (id_aluno, id_disciplina, id_curso, etc.).
disciplinas: Tabela com informações das disciplinas (id_disciplina, nome, descrição, carga, etc.).
professores: Tabela com informações dos professores (id_professor, nome, etc.).
turmas: Tabela com informações das turmas de disciplinas (id_turma, id_professor, etc.).

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

4. Licença
Este código é de uso livre para qualquer aplicação acadêmica ou educacional, sujeito às leis de direitos autorais aplicáveis.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
