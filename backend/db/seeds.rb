user = User.create!(
  name: "Usuário Teste",
  email: "teste@notevault.com",
  password: "123456"
)

nb1 = user.notebooks.create!(name: "Pessoal")
nb2 = user.notebooks.create!(name: "Trabalho")

nb1.notes.create!(
  title: "Bem-vindo ao NoteVault! 🎉",
  content: "<h1>Bem-vindo ao NoteVault</h1><p>Este é seu bloco de notas personalizado. Aqui você pode criar e organizar suas notas com <strong>formatação rica</strong>.</p><h2>O que você pode fazer</h2><ul><li>Criar títulos e subtítulos</li><li>Usar <em>itálico</em> e <strong>negrito</strong></li><li>Inserir imagens</li><li>Usar o sumário automático</li></ul><h3>Comece agora</h3><p>Clique em qualquer area para editar. O conteúdo é salvo automaticamente.</p>"
)

nb2.notes.create!(
  title: "Reunião de planejamento",
  content: "<h1>Reunião Q2</h1><h2>Pauta</h2><ul><li>Revisão de metas</li><li>Novos projetos</li></ul><h2>Ações</h2><p>Definir responsáveis e prazos.</p>"
)

puts "Seed criado! Login: teste@notevault.com / 123456"
