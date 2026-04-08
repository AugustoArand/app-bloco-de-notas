<template>
  <div class="info-page">
    <div class="info-view">
      <section class="info-card">
        <h1>Contato</h1>
        <p>Fale com o time do Duck Notes para suporte e sugestões.</p>

        <div class="contact-grid">
          <div class="contact-item">
            <span class="label">E-mail</span>
            <span class="value">contato@ducknotes.app</span>
          </div>
          <div class="contact-item">
            <span class="label">Suporte</span>
            <span class="value">Segunda a Sexta, 9h às 18h</span>
          </div>
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
}

h1 {
  font-size: 24px;
  margin-bottom: 12px;
}

p {
  color: var(--text-2);
  margin-bottom: 16px;
}

.contact-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 12px;
}

.contact-item {
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 12px;
  background: var(--panel);
}

.label {
  display: block;
  font-size: 12px;
  color: var(--text-3);
}

.value {
  display: block;
  margin-top: 4px;
  color: var(--text-2);
}
</style>
