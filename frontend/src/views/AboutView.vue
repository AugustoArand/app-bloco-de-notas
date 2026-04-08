<template>
  <div class="info-page">
    <div class="info-view">
      <section class="info-card">
        <h1>Sobre o Duck Notes</h1>
        <p>
          O Duck Notes foi criado para organizar ideias com rapidez, combinando cadernos,
          tags, busca e edição rica em um fluxo simples.
        </p>
        <ul>
          <li>Edição com texto formatado e imagens</li>
          <li>Organização por cadernos e tags</li>
          <li>Histórico recente para acesso rápido</li>
        </ul>
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
}

h1 {
  font-size: 24px;
  margin-bottom: 12px;
}

p {
  color: var(--text-2);
  margin-bottom: 12px;
}

ul {
  padding-left: 20px;
  color: var(--text-2);
}
</style>
