# Guia de arquitetura e desenvolvimento de Ovation

## Escopo e fontes de verdade

Ovation é um produto de biblioteca SwiftUI distribuída via Swift Package
Manager, para pedir a avaliação de um app iOS na App Store por meio de um sheet
que leva à página oficial de escrever avaliação e oferece um caminho de contato
por e-mail. O pacote não chama o pedido nativo (`RequestReviewAction`).

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
- Projeto/workspace: `Package.swift` na raiz. App de exemplo em
  `Demo/OvationDemo.xcodeproj` (objectVersion 77, pasta sincronizada
  `Demo/Sources`, `XCLocalSwiftPackageReference ".."`), bundle
  `com.didisouzacosta.OvationDemo`, iOS 26.0, Swift 6.0,
  `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` e
  `SWIFT_APPROACHABLE_CONCURRENCY = YES`, como os apps do dono.
- Schemes ou targets: produto `Ovation`; targets `Ovation` e `OvationTests`
  (scheme gerado `Ovation`); scheme `OvationDemo`.
- Linguagem e versão: `swift-tools-version: 6.2`, `swiftLanguageModes: [.v6]`,
  `defaultLocalization: "en"`, só `.iOS(.v26)`. Sem `defaultIsolation` e sem
  upcoming features: uma biblioteca é usada de qualquer isolamento, e o padrão
  `MainActor` (SE-0466) seria errado para os modelos; o isolamento é explícito
  por tipo. Toolchain local em 2026-10-29: Xcode 27.2 (27B48), Apple Swift
  6.4.2; não há toolchain 6.2 para compilar localmente (pendência).
- Dependências permitidas: nenhuma de terceiros. Frameworks da Apple: SwiftUI,
  Foundation, Observation, os e UIKit (só `UIPasteboard`). Sem StoreKit. Novas
  dependências exigem aprovação explícita.
- Requisitos de hardware: nenhum além do Simulator para build, testes e
  previews. A página de escrever avaliação e o Mail só têm comportamento real
  em aparelho.

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
não há `App/`, porque a composição acontece no app integrador. Estrutura real
(2026-10-29), no padrão do WhatsNewKit, com `Core/Platform`:

```text
Sources/Ovation/
├── Core/
│   ├── Localization/   OvationLocalized (bundle .module) e OvationResolvedTexts
│   ├── Models/         configuração, card, origem, textos, tema, estilo de fonte,
│   │                   eventos, apresentação e desfecho
│   ├── Persistence/    OvationStorage (@MainActor) e UserDefaultsOvationStorage
│   ├── Platform/       links (write-review e mailto), nome do app, área de transferência
│   └── Presentation/   regra, contexto, política pura e sessão em memória
├── Features/
│   ├── Presentation/   View+OvationReview, modifier com trigger, modifier forçado
│   │                   e OvationPresentationViewModel
│   └── ReviewSheet/    OvationSheet (interno), OvationSheetViewModel, ação,
│                       layout, paginação do carrossel, fixtures (#if DEBUG) e
│                       Components/ (cabeçalho, destaque, card, carrossel, rodapé,
│                       estilo do botão, brilho)
└── Resources/          Localizable.xcstrings (10 chaves, en, pt-BR, es, fr, ja)
                        e PrivacyInfo.xcprivacy
Tests/OvationTests/
├── Core/               Localization, Models, Persistence, Platform, Presentation
├── Features/           Presentation, ReviewSheet
├── Documentation/      ReadmeExampleTests
└── Support/            dublês e leitores de fonte e de bundle
Demo/
└── Sources/            App/, Core/Review (região README:configuration),
                        Features/Levels (região README:view), Features/Home
```

- Entrada e composição: o modifier público recebe o gatilho e a configuração e
  cria o seu ViewModel com `UserDefaultsOvationStorage(namespace:)` e
  `OvationSession.shared`; testes injetam armazenamento, sessão e relógio.
- Domínio: política de exibição pura (`OvationPolicy`: já avaliou → sessão →
  regra), regras compostas (`OvationRule`) e paginação pura do carrossel
  (`OvationCarouselPaging`).
- Features: o sheet é interno (`OvationSheet`); a variante
  `ovationReview(isPresented:configuration:)` cobre previews e debug. Um sheet
  público permitiria burlar as regras e alargaria o contrato. Componentes
  puramente visuais recebem valores prontos e closures.
- Infraestrutura: `UserDefaults`, `openURL` do ambiente SwiftUI (com o
  completion `accepted` para o `mailto:`), `UIPasteboard` e `os.Logger`.
- Testes: Swift Testing, espelhando `Core/` e `Features/`, mais testes de fonte
  (layout, acessibilidade, concorrência e manifesto) e do README.

## Estado, concorrência e efeitos

- Fonte de verdade de cada estado:
  - sheet visível: `OvationPresentationViewModel.activePresentation` (um por
    modifier), com a configuração congelada na apresentação;
  - alerta de e-mail indisponível: `OvationSheetViewModel`;
  - página visível do carrossel: `@State` do `OvationCarousel`
    (`scrollPosition(id:)`);
  - "já avaliou" e contadores: `UserDefaults` via `OvationStorage`;
  - "já exibido nesta sessão": `OvationSession.shared`, só em memória, com a
    reserva do sheet decidido até ele aparecer ou ser liberado.
- Isolamento de atores e tarefas: ViewModels `@MainActor @Observable` em
  `@State`; armazenamento e sessão `@MainActor`; modelos públicos value types
  `Sendable` não isolados; `OvationRule` guarda uma closure `@Sendable`. Sem
  `Task {}`, `Task.detached`, `@unchecked Sendable`, `nonisolated(unsafe)` ou
  GCD (garantido por teste). O trabalho assíncrono são dois `.task(id:)` com
  `Task.sleep`: o do carrossel, cancelado quando a View some ou o `tick` muda,
  e o da aparição (`awaitingPresentationID`), que libera o sheet e a reserva da
  sessão depois de `OvationReview.appearanceTimeout` ou quando a View sai.
- Cancelamento e invalidação: um gatilho com o sheet decidido ou visível é
  ignorado e não conta; a decisão reserva a sessão
  (`OvationSession.reservePresentation`: outro modifier não decide enquanto há
  reserva ou apresentação) e só confirma a sessão, grava `presentationCount` e
  `lastPresentationDate` e emite `.presented` quando o sheet aparece de fato
  (`onAppear` → `sheetAppeared()` → `confirmPresentation`; uma reserva perdida
  devolve nil e libera o sheet); um sheet decidido que não aparece em
  `OvationReview.appearanceTimeout` (1 s, público; por exemplo, outro modal
  sobre a janela) ou cuja View sai é liberado com a reserva por um
  `.task(id:)`, e `finish` antes da aparição também libera, sem gastar a sessão
  nem as contagens. `releaseIfNotShown` libera também quando a task é
  cancelada (a View apresentadora saiu com o sheet a caminho; coberto por
  teste de fonte). Depois da aparição, o evento terminal depende de a View
  apresentadora continuar na hierarquia até o sheet fechar: o integrador
  aplica o modifier numa View estável (no PotionPals, a raiz). A aparição e a
  gravação só na aparição foram conferidas no iOS 27.2 (Simulator); a
  liberação sem aparição fica coberta por testes (a recusa não se reproduziu
  no Simulator); o iOS 26 fica como pendência externa (aparelho ou runtime
  iOS 26). `finish` é
  idempotente (um único evento terminal, só para um sheet que apareceu); o
  avanço do carrossel reinicia a contagem a cada troca de página, gesto ou
  mudança de acessibilidade.
- Limites de memória e trabalho pendente: o carrossel renderiza os cards uma
  vez (sem cópias); nenhuma fila de pedidos pendentes.
- Permissões, rede, arquivos e outros efeitos: sem permissões e sem rede
  própria. Efeitos externos só por `openURL`; escrita só das chaves do pacote.

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
  sobrescrever título, descrição, botão, link e assunto. Os padrões nunca pedem
  nota específica, e o link de feedback é neutro.
- Textos truncam em vez de empurrar o layout (limites em
  `OvationSheetLayout`); cards têm altura fixa (192 pt escalados) com conteúdo
  a partir do topo.
- O Ovation não chama `RequestReviewAction`.
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
- Estados mínimos do sheet: "Escrever uma avaliação", sem cards, cards de
  destaque (sem autor e estrelas), fala de personagem (só o nome, sem símbolo
  de pessoa), tema arredondado, sem e-mail, textos longos
  e Dynamic Type grande. Carrossel: "Avançando", "Manual", "Um card", "Sem
  cards" e conteúdos diferentes com altura fixa. Fixtures em `#if DEBUG`, com
  IDs estáveis e depoimentos marcados como exemplo.

## Testes e validação

Registre comandos e resultados reais. Separe compilação e Simulator de
validação em dispositivo físico e de serviços externos.

- Testes unitários: Swift Testing (proibidos testes de UI e XCUIAutomation).
  Como o pacote é só iOS, rode no Simulator:
  `xcodebuild test -scheme Ovation -destination 'platform=iOS Simulator,name=iPhone 17'`.
  Resultado em 2026-10-29: 110 testes em 18 suítes passando.
- Testes de integração: `ReadmeExampleTests` garante que os blocos do README
  são idênticos às regiões compiladas do Demo; integração real no PotionPals.
- Build: `xcodebuild build -scheme Ovation -destination 'generic/platform=iOS Simulator'`
  (sem avisos) e
  `xcodebuild -project Demo/OvationDemo.xcodeproj -scheme OvationDemo -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`.
- Lint: `scripts/lint-swift.sh --fix`, `scripts/lint-swift.sh --add-marks`
  (com as ferramentas fixadas no `PATH`, porque o script de MARKs chama
  `swiftlint` direto) e `scripts/lint-swift.sh` (0 violações).
- Simulator (Demo, iPhone 17, 2026-10-29): apresentação automática, uma vez
  por sessão, "já avaliou", X, alerta sem Mail e cópia, carrossel automático e
  manual, Reduce Motion, Dynamic Type máximo e variante forçada. Comparado às
  telas 2:88 e 5:125 do Figma.
- Dispositivo físico: página de escrever avaliação, Mail e fluidez do carrossel
  com Instruments. Pendente.
- Serviços live: App Store (escrever avaliação) e Mail. Pendente.
- Validações ainda não executadas: build com Xcode 26.x / Swift 6.2.

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
- Riscos conhecidos: o sheet é apresentado pelo app (guideline 5.6.1): ele não
  coleta nota, usa o link documentado para avaliações iniciadas pelo usuário,
  não pede nota específica, não filtra quem pode avaliar e precisa continuar
  raro (uma vez por sessão, nunca depois de "já avaliou", mais a regra do app);
  "já avaliou" é uma aproximação.
