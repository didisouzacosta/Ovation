# Guia de arquitetura e desenvolvimento de Ovation

## Escopo e fontes de verdade

Ovation é um produto de biblioteca SwiftUI distribuída via Swift Package
Manager, para pedir a avaliação de um app iOS na App Store por meio de um sheet
com o pedido nativo, a página de escrever avaliação e um caminho de feedback por
e-mail.

As fontes deste checkout são, nesta ordem:

- AGENTS.md — regras de engenharia, coordenação e validação.
- PROJECT_BRIEF.md — produto, fluxos, estados e pendências.
- README.md — requisitos públicos e comandos.
- Código e configuração existentes — comportamento efetivamente conectado.

Não trate um tipo, string, pacote ou serviço sem callsite de produção como uma
feature disponível. Não faça migrações de nomes, pastas ou arquitetura sem
escopo explícito.

A API pública (modifier, configuração, cards, textos, tema, regras e eventos) e
as chaves de `UserDefaults` são um contrato com os apps integradores: qualquer
mudança de assinatura, semântica ou chave exige decisão explícita e nota no
README. O exemplo de implementação do README precisa compilar no repositório
(Demo ou arquivo compilado pela suíte), para não divergir da API.

Layout de referência aprovado:
<https://www.figma.com/design/07ILZlO32KAJoY4zmtXGw1>.

## Baseline efetiva

- Plataforma e versão mínima: iOS 26.0, só iPhone e iPad via SwiftUI; sem
  macOS.
- Projeto/workspace: `Package.swift` na raiz (a criar). App de exemplo
  planejado em `Demo/OvationDemo.xcodeproj`, referenciando o pacote local
  (`..`), no mesmo padrão do WhatsNewKit.
- Schemes ou targets: produto `Ovation`; targets `Ovation` e `OvationTests`;
  scheme `OvationDemo` quando o Demo existir.
- Linguagem e versão: `swift-tools-version: 6.2`, Swift 6 language mode. O
  isolamento padrão e as upcoming features são decididos no plano da primeira
  implementação e registrados aqui. Toolchain local em 2026-10-29: Xcode 27.2
  (27B48), Apple Swift 6.4.2.
- Dependências permitidas: nenhuma de terceiros. Frameworks da Apple: SwiftUI,
  StoreKit (pedido nativo) e Foundation. Novas dependências exigem aprovação
  explícita.
- Requisitos de hardware: nenhum além do Simulator para build, testes e
  previews. O pedido nativo, a página de escrever avaliação e o Mail só têm
  comportamento real em aparelho.

## Coordenação dos subagentes

Use os níveis de execução e os papéis definidos e detalhados no `AGENTS.md`,
executados por subagentes que o agente principal cria com a ferramenta em uso:

- Nível 0 (direto): o agente principal executa sem subagentes.
- Nível 1 (padrão): subagente no papel Developer com plano curto → revisão por
  subagente no papel Manager, somente leitura.
- Nível 2 (completo): Manager planeja → Developer implementa e valida →
  Manager revisa.

Correções voltam ao Developer e passam por re-revisão até não restarem
apontamentos `BLOCKING`. A base não fixa agentes, nomes nem modelos; registre
aqui somente preferências ou exceções do projeto.

- Nível mínimo por área ou tipo de tarefa: nível 2 para qualquer mudança na API
  pública, nas regras de exibição (incluindo "já avaliou" e uma vez por sessão)
  ou nas chaves de persistência.

## Arquitetura

O target SwiftPM adapta a estrutura do `SWIFT_REFERENCE.md` a uma biblioteca:
não há `App/`, porque a composição acontece no app integrador. Estrutura
planejada, no padrão do WhatsNewKit (confirme e atualize quando o código
existir):

```text
Sources/Ovation/
├── Core/
│   ├── Localization/   strings do bundle .module
│   ├── Models/         configuração, card, textos, tema, regra e eventos
│   ├── Persistence/    armazenamento de "já avaliou" e contadores (UserDefaults)
│   └── Presentation/   política de exibição e sessão em memória
├── Features/
│   ├── Presentation/   modifier público com trigger + ViewModel da apresentação
│   └── ReviewSheet/    sheet, ViewModel das ações, layout, fixtures de preview
│                       e Components/ (cabeçalho, card, marquee, botão, link)
└── Resources/          Localizable.xcstrings (en, pt-BR, es, fr, ja)
Tests/OvationTests/
├── Core/               Models, Persistence, Presentation
├── Features/           Presentation, ReviewSheet
└── Support/            dublês compartilhados
Demo/
└── Sources/            app de exemplo (Core/, Features/), com o exemplo do README
```

- Entrada e composição: o modifier público recebe o gatilho e a configuração e
  cria o seu ViewModel de apresentação com o armazenamento padrão; testes
  injetam o armazenamento e o relógio.
- Domínio: política de exibição em funções puras (já avaliou → sessão → regra
  do app) e a máquina de estados das ações do sheet.
- Features: sheet público e componentes puramente visuais que recebem valores
  prontos e closures.
- Infraestrutura: `UserDefaults`, `requestReview` e `openURL` do ambiente
  SwiftUI, URL de escrever avaliação e `mailto:`.
- Componentes compartilhados: `Features/ReviewSheet/Components/`.
- Testes: Swift Testing, espelhando `Core/` e `Features/`.

## Estado, concorrência e efeitos

- Fonte de verdade de cada estado:
  - sheet visível: ViewModel da apresentação (um por modifier);
  - etapa do botão ("Continuar" ou "Escrever uma avaliação"): ViewModel do
    sheet;
  - "já avaliou" e contadores da regra: `UserDefaults` via protocolo de
    armazenamento;
  - "já exibido nesta sessão": estado em memória compartilhado por todos os
    modifiers, nunca persistido.
- Isolamento de atores e tarefas: ViewModels `@MainActor @Observable`, mantidos
  em `@State` pela View dona; modelos públicos são value types `Sendable` sem
  `@unchecked`; o estado de sessão fica no ator principal. Sem `Task` não
  estruturada.
- Cancelamento e invalidação de resultados obsoletos: um gatilho recebido com
  o sheet já visível é ignorado; a animação do marquee para quando o sheet some
  ou com Reduce Motion.
- Limites de memória e trabalho pendente: o marquee duplica a lista só o
  necessário para a rolagem infinita; nenhuma fila de pedidos pendentes.
- Permissões, rede, arquivos e outros efeitos: sem permissões e sem rede
  própria. Efeitos externos só por `requestReview` e `openURL`; escrita só das
  chaves do pacote.

## Regras de implementação

- Injete serviços e protocolos nas fronteiras de comportamento.
- Use dublês nos testes e nas previews.
- Preserve cancelamento, isolamento e tratamento de erros.
- Não adicione dependências sem aprovação explícita.
- Mantenha segredos fora do repositório.
- Preserve alterações locais não relacionadas.
- Regras de elegibilidade ficam na política de exibição; os ViewModels só as
  orquestram. Toda mudança nessas regras começa por um teste em
  `Tests/OvationTests/Core/Presentation/` ou nos testes dos ViewModels.
- "Já avaliou" só é marcado ao abrir "Escrever uma avaliação". A regra de uma
  exibição por sessão é interna e não pode virar opção da configuração.
- Strings visíveis passam pelo helper de localização do pacote e entram no
  `Localizable.xcstrings` em todos os idiomas existentes; o integrador pode
  sobrescrever cada texto.
- Os cards de exemplo (depoimentos fictícios) só existem em previews, testes e
  Demo, marcados como exemplo; nunca como padrão da configuração.
- Modelos, constantes de layout e fixtures ficam em arquivos próprios, fora dos
  arquivos que declaram `View`.
- Componentes com estado ou regras usam ViewModel; componentes puramente
  visuais não (o `SWIFT_REFERENCE.md` prevalece sobre o `swiftui-view-refactor`).

## Estilo e formatação Swift

- Convenção geral: [Google Swift Style Guide](https://google.github.io/swift/),
  com a exceção declarada de 4 espaços e 120 colunas, aplicada a todo código Swift, incluindo testes.
- Cadeias de modificadores SwiftUI: cada modificador em sua própria linha,
  conforme os exemplos da Apple em
  [Configuring Views](https://developer.apple.com/documentation/swiftui/configuring-views).
- `MARK:` obrigatório e espaçamento entre blocos conforme `SWIFT_REFERENCE.md`.
- Bootstrap/update sincronizam `.swiftlint.yml`, `.swiftformat`, `scripts/lint-swift.sh` e `scripts/fix-swift-spacing.pl` com manifesto e proteção de conflitos.
- Baseline desta base: SwiftLint 0.63.2 e SwiftFormat 0.63.0; confirme a instalação no consumidor e no CI.
- `scripts/lint-swift.sh` é o gate executável local/CI, verifica versões e cobre somente fontes, testes e `Package.swift` nos caminhos do consumidor. Conecte esse comando ao job obrigatório de CI do projeto.
- A base não distribui workflow de CI; chame `scripts/install-swift-tools.sh` e `scripts/lint-swift.sh` no CI do projeto (por exemplo, `ci_scripts/ci_post_clone.sh` no Xcode Cloud).
- Formate desde a criação: `scripts/lint-swift.sh --fix`; rascunhe MARKs ausentes com `scripts/lint-swift.sh --add-marks` e revise os nomes.
- Ferramentas: `scripts/lint-swift.sh` baixa sozinho as versões fixas (com SHA-256 conferido) para o cache por usuário `~/Library/Caches/swift-quality-tools` quando não as encontra no `PATH` ou no Homebrew; `scripts/install-swift-tools.sh` faz o mesmo antecipadamente (CI, Xcode Cloud, trabalho offline).
- Fase de build do Xcode (target sem sandbox de scripts): `scripts/lint-swift.sh --format-only`.
- Cobertura neste projeto: `Sources/`, `Tests/`, `Package.swift` e
  `Demo/Sources/`. Não coloque código Swift do Demo fora de `Demo/Sources`.
- Ainda não há CI; quando houver, ele chama `scripts/install-swift-tools.sh` e
  `scripts/lint-swift.sh`.
- Exceções locais justificadas: nenhuma.

## Previews SwiftUI

- Toda `View` criada deve ter `#Preview` para cada estado de apresentação
  suportado, incluindo os estados de carregamento, vazio, erro e sucesso quando
  fizerem parte do contrato da tela.
- Use `@Previewable` em cada propriedade dinâmica local necessária para
  configurar esses estados dentro do corpo de `#Preview`. Esse macro só é
  válido nesse corpo e não substitui a declaração dos previews para cada estado.
- Injete dados e dependências determinísticos; não conecte previews a serviços
  reais, rede, autenticação ou arquivos mutáveis do usuário.
- Convenção confirmada com a documentação da Apple:
  [Previewable](<https://developer.apple.com/documentation/swiftui/previewable()>).
- Estados mínimos do sheet: "Continuar", "Escrever uma avaliação", marquee
  vazio, cards de destaque (sem autor e estrelas) e tema alternativo. Fixtures
  em `#if DEBUG`, com IDs estáveis e um `UserDefaults` de suíte própria.

## Testes e validação

Registre comandos e resultados reais. Separe compilação e Simulator de
validação em dispositivo físico e de serviços externos.

- Testes unitários: Swift Testing (proibidos testes de UI e XCUIAutomation).
  Como o pacote é só iOS, rode no Simulator:
  `xcodebuild test -scheme Ovation -destination 'platform=iOS Simulator,name=iPhone 17'`.
  Ainda não executado: não há código.
- Testes de integração: o exemplo do README compilado no Demo ou na suíte;
  integração real no PotionPals.
- Build: `xcodebuild build -scheme Ovation -destination 'generic/platform=iOS Simulator'`;
  Demo com `-scheme OvationDemo` quando existir.
- Simulator: verificação visual do sheet contra o Figma (telas 01, 02 e 03).
- Dispositivo físico: pedido nativo, página de escrever avaliação e Mail.
  Pendente.
- Serviços live: App Store (pedido nativo e escrever avaliação) e Mail.
  Pendente.
- Validações ainda não executadas: todas as de código.

## Entrega

- Checklist de aceitação: critérios do plano atendidos; testes, build e
  `scripts/lint-swift.sh` passando; previews de todos os estados; exemplo do
  README compilando.
- Arquivos de documentação a atualizar: README.md (uso, regras, exemplo),
  PROJECT_BRIEF.md (recursos disponíveis, mapa de fontes, validações) e este
  guia (arquitetura real, isolamento, comandos e resultados).
- Artefatos temporários a limpar: DerivedData temporário e screenshots da
  validação no Simulator criados pela tarefa.
- Estado de commit esperado: sem commit pelos subagentes; commits e push só a
  pedido do dono. Releases com tag SemVer para consumo por versão exata.
- Riscos conhecidos: guideline 5.6.1 (o sheet não coleta nota e só encaminha
  para os fluxos oficiais); "já avaliou" é uma aproximação; o pedido nativo não
  aparece no TestFlight.
