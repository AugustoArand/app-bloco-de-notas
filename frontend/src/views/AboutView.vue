<template>
  <div class="info-page">
    <div class="info-view">
      <section class="info-card">
        <h1>Sobre o Duck Notes</h1>
        <p class="intro">
          O Duck Notes e uma plataforma de produtividade para centralizar estudos, ideias e execucao de tarefas,
          com organizacao flexivel, edicao rica e fluxo visual em Kanban.
        </p>

        <div class="feature-block">
          <h2>Organizacao e navegacao</h2>
          <ul>
            <li>Cadernos com favoritos e contagem de notas</li>
            <li>Tags com gerenciamento completo por modal</li>
            <li>Painel de notas recentes e filtros por tag</li>
            <li>Busca de notas por caderno e pesquisa global</li>
          </ul>
        </div>

        <div class="feature-block">
          <h2>Editor e conteudo</h2>
          <ul>
            <li>Editor rico com formatacao de texto e anexos de imagem</li>
            <li>Diagramas por nota para estruturar ideias visuais</li>
            <li>Checklist visual em anotacoes rapidas com estado salvo</li>
            <li>Capa de perfil personalizada por usuario</li>
          </ul>
        </div>

        <div class="feature-block">
          <h2>Kanban de tarefas</h2>
          <ul>
            <li>Boards personalizados, com criacao ilimitada</li>
            <li>Mover tarefas por arrastar e soltar e por botao de proximo board</li>
            <li>Minimizar e expandir boards para facilitar backlog grande</li>
            <li>Arquivar tarefas concluidas e consultar historico de arquivadas</li>
            <li>Persistencia em banco por usuario para uso em qualquer dispositivo</li>
          </ul>
        </div>

        <div class="feature-block">
          <h2>IA e produtividade</h2>
          <ul>
            <li>Resumo automatico de textos</li>
            <li>Traducao de conteudo e termos tecnicos</li>
            <li>Geracao assistida de texto</li>
            <li>Anotacoes rapidas em painel lateral com edicao por modal</li>
          </ul>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.info-page {
  width: 100%;
  min-height: 100vh;
  background: var(--bg);
}

.info-view {
  min-height: 100vh;
  width: 100%;
  padding: 36px;
  display: flex;
  justify-content: center;
  align-items: flex-start;
}

.info-card {
  width: min(760px, 100%);
  max-width: 760px;
  background: var(--surface);
  border: 1px solid var(--border-soft);
  border-radius: var(--radius-lg);
  padding: 24px;
}

@media (max-width: 768px) {
  .info-view {
    padding: 20px;
  }

  .info-card {
    padding: 18px;
  }
}

h1 {
  font-size: 24px;
  margin-bottom: 12px;
}

.intro {
  color: var(--text-2);
  margin-bottom: 16px;
}

h2 {
  font-size: 16px;
  margin: 0 0 8px;
}

.feature-block {
  border: 1px solid var(--border);
  border-radius: var(--radius);
  background: var(--panel);
  padding: 12px;
  margin-top: 12px;
}

ul {
  margin: 0;
  padding-left: 18px;
  color: var(--text-2);
  line-height: 1.55;
}
</style>
