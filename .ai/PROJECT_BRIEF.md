# Ovation — Brief do produto

## Identidade do produto

- Nome: Ovation (pacote, produto, target e prefixo dos tipos públicos).
- Plataforma: biblioteca SwiftUI distribuída via Swift Package Manager, só iOS,
  a partir do iOS 26 (mesmo piso dos apps do dono: PotionPals, Pillo,
  HorseScore, DuoTake e TelePro).
- Problema que resolve: pedir a avaliação na App Store do jeito certo. A regra
  antiga ("a cada 3 aberturas, na primeira ação, chama o pedido nativo") não
  converte: o pedido aparece fora de contexto e o usuário não sabe por que
  avaliar.
- Público principal: os apps iOS do dono e, por extensão, qualquer app SwiftUI
  que queira um pedido de avaliação reutilizável.
- Proposta de valor: um sheet que explica o pedido (louros, cinco estrelas,
  título, descrição e um carrossel de cards), leva à página oficial de escrever
  avaliação e oferece um caminho de contato por e-mail a qualquer usuário. O
  app integrador só informa os dados e liga um modifier com um gatilho.

## Experiência principal

Layout aprovado no Figma:
<https://www.figma.com/design/07ILZlO32KAJoY4zmtXGw1> (página "ReviewKit":
telas 01, 02 e 03, componentes e painel de regras).

### Fluxos

- Fluxo de entrada: o app integrador aplica `ovationReview(_:trigger:onEvent:)`
  numa View e passa um gatilho (`Equatable`). A cada mudança do gatilho (o
  valor inicial não conta), o pacote confere, nesta ordem: App Store ID válido
  (só dígitos); o usuário ainda não avaliou; conta o gatilho; o sheet ainda não
  apareceu nesta sessão; a regra do app permite. Só então abre o sheet. Um
  gatilho recebido com o sheet visível é ignorado e não é contado. A
  apresentação só é registrada (sessão, contagem, data e `.presented`) quando o
  sheet aparece de fato; até lá, a decisão reserva a sessão (outro modifier não
  decide). Se outro modal impedir a aparição, ela é liberada, com a reserva, em
  `OvationReview.appearanceTimeout` (1 s, público) sem gastar nada. O SwiftUI
  pode dispensar um modal de fora do SwiftUI (UIKit) para apresentar o sheet: o
  integrador dispara só em momento quieto (README).
- Fluxo principal:
  1. O sheet abre (detent grande, sem grabber), em esquema escuro, com o botão
     de fechar do sistema (`Button(role: .close)`) à esquerda na toolbar.
  2. "Escrever uma avaliação" (único estado do botão) abre
     `https://apps.apple.com/app/id<ID>?action=write-review`, marca o usuário
     como "já avaliou" e fecha o sheet.
- Fluxos alternativos:
  - "Tem alguma sugestão? Fale com a gente" abre o Mail (`mailto:`) endereçado
    ao e-mail de suporte. Se o sistema aceitar, fecha o sheet sem marcar como
    avaliado; sem app de e-mail, um alerta mostra o endereço com "Copiar
    endereço" e "OK", e o sheet continua aberto.
  - O X (ou o gesto de arrastar) fecha o sheet. Não marca como avaliado.
  - O Ovation nunca chama o pedido nativo (`RequestReviewAction`); o app pode
    chamá-lo por conta própria, em outro momento.
  - Debug e previews: `ovationReview(isPresented:configuration:)` mostra o sheet
    sem regras, sem ler nem gravar estado e sem eventos.

### Estados

- Botão: só "Escrever uma avaliação".
- Carrossel paginado: um card por página, centralizado, com os vizinhos nas
  bordas; avança sozinho a cada 4 s e volta ao primeiro depois do último;
  swipe manual sempre disponível. Com Reduce Motion, VoiceOver ou um card só,
  não avança sozinho. Com a lista vazia, o carrossel some e o conteúdo continua
  centralizado.
- Cards: altura fixa de 192 pt (escalada com Dynamic Type), conteúdo empilhado
  a partir do topo; avaliação (estrelas, título, texto, autor com o símbolo de
  pessoa e origem), destaque (só título e texto) ou fala de personagem do
  próprio app (título, texto e só o nome, sem estrelas, origem nem símbolo de
  pessoa: `showsAuthorSymbol` exige nota ou origem). A origem é `.appStore` ou
  `.testFlight`; card do TestFlight nunca mostra estrelas.
- Textos truncam com reticências em vez de empurrar o layout: título 2 linhas,
  descrição 3, link 1, botão 1; no card, título 1, texto 4 (encolhe primeiro),
  autor 1 e origem 1. Dynamic Type limitado a `accessibility2`; o corpo rola só
  em telas baixas, recortado acima do rodapé.
- Sem e-mail válido (sem "@"): o link de feedback some.
- Usuário que já avaliou: o sheet nunca mais aparece e nada mais é contado.
- Sheet já exibido nesta sessão (vida do processo): não reaparece até o app ser
  reaberto.

## Recursos e limites

- Recursos disponíveis: pacote publicado na versão 1.0.0 (tag `1.0.0`):
  configuração (App Store ID, e-mail, nome do app, cards, textos, tema,
  regra e namespace), sheet, carrossel, regras prontas, eventos, persistência,
  variante forçada, catálogo em 5 idiomas, `PrivacyInfo.xcprivacy` e o Demo.
- Recursos premium ou condicionais: nenhum.
- Limites conhecidos:
  - A Apple não informa se o usuário avaliou. "Já avaliou" é uma aproximação:
    o usuário abriu a página de escrever avaliação.
  - Os cards devem conter avaliações reais, destaques verdadeiros do app ou
    falas dos personagens do próprio app, atribuídas a eles, sem nota nem
    origem e nunca apresentadas como avaliações de usuários. Depoimentos
    inventados não podem ser apresentados como reais; os depoimentos das
    previews e do Demo são exemplos marcados.
  - O Simulator não tem App Store nem Mail: a página de escrever avaliação e o
    Mail só têm comportamento real em aparelho.
- Textos padrão (en / pt-BR), sobrescrevíveis por `OvationTexts`:
  - título: "Help us grow" / "Nos ajude a crescer";
  - descrição: "Your review helps more people discover %@." / "Sua avaliação
    ajuda mais pessoas a descobrirem o %@." (sem pedir nota específica);
  - botão: "Write a review" / "Escrever uma avaliação";
  - link: "Have a suggestion? Get in touch" / "Tem alguma sugestão? Fale com a
    gente" (neutro, para qualquer usuário);
  - assunto do e-mail: "Feedback about %@" / "Feedback sobre o %@".
- Regras prontas: `.always`, `.fromTrigger(n)`, `.everyTrigger(n)`,
  `.custom { }` e o combinador `.waitingDays(d)`; `allows(_:)` e
  `OvationContext` são públicos.
- Eventos: `presented`, `reviewPageOpened`, `feedbackOpened`, `dismissed`.
- Primeiro integrador: PotionPals, com a dependência remota exata `1.0.0`.

## Dados e persistência

- Modelos: configuração, card, origem, textos, tema, estilo de fonte, regra,
  contexto e eventos (value types `Sendable`, não isolados).
- Fonte primária dos dados: o app integrador.
- Armazenamento local: `UserDefaults.standard` com as chaves
  `<namespace>.Ovation.hasReviewed`, `.triggerCount`, `.presentationCount` e
  `.lastPresentationDate`; namespace padrão = bundle id, senão "Ovation". A
  sessão fica só em memória (`OvationSession.shared`, `@MainActor`).
- Sincronização ou serviços externos: App Store (URL de escrever avaliação) e
  Mail (`mailto:`). Sem rede própria e sem StoreKit.
- Regras de migração e recuperação: chaves estáveis; mudar o nome ou a
  semântica de uma chave é quebra de contrato e exige nota no README. O estado
  fica no aparelho: não entra nos backups do app e se perde numa reinstalação.

## Validação

Separe evidências de código, testes, Simulator, dispositivo físico e serviços
externos. Não trate validação local como prova de comportamento live.

- Validações concluídas (2026-10-29, Xcode 27.2, Swift 6.4.2):
  - layout aprovado pelo dono no Figma;
  - 110 testes Swift Testing em 18 suítes (`xcodebuild test`, iPhone 17,
    iOS 27.2);
  - build do pacote e do Demo para o Simulator sem avisos;
  - `scripts/lint-swift.sh` com 0 violações;
  - Simulator (Demo, iPhone 17): apresentação na 3ª vitória, contagem e data
    gravadas, uma vez por sessão, "Escrever uma avaliação" grava "já avaliou" e
    fecha, nada é contado depois, X fecha, alerta sem Mail e cópia do endereço,
    carrossel avançando a cada 4 s e por swipe, Reduce Motion sem avanço,
    Dynamic Type no maior tamanho (limitado a `accessibility2`) com truncagem,
    variante forçada sem gravar nada.
- Validações pendentes: compilar com o toolchain Swift 6.2 / Xcode 26.x (só há
  o 6.4.2 instalado); página de escrever avaliação e Mail em aparelho; fluidez
  do carrossel em aparelho com Instruments.
- Condições de hardware, conta ou serviço: a página de escrever avaliação só
  abre a App Store num aparelho com o app publicado; o `mailto:` exige o Mail
  configurado.

## Mapa de fontes

- Modifier público e variante forçada:
  `Sources/Ovation/Features/Presentation/View+OvationReview.swift`,
  `OvationPresentationModifier.swift`, `OvationForcedPresentationModifier.swift`.
- Decisão de apresentação e "já avaliou": `OvationPresentationViewModel.swift`,
  `Core/Presentation/OvationPolicy.swift`, `OvationRule.swift`,
  `OvationContext.swift`, `OvationSession.swift`.
- Persistência: `Core/Persistence/OvationStorage.swift`,
  `UserDefaultsOvationStorage.swift`.
- Sheet e ações: `Features/ReviewSheet/OvationSheet.swift`,
  `OvationSheetViewModel.swift`, `OvationSheetAction.swift`,
  `OvationSheetLayout.swift`, `OvationCarouselPaging.swift`,
  `OvationCarouselTick.swift` e `Components/`.
- Links, nome do app e área de transferência: `Core/Platform/`.
- Textos: `Core/Localization/` e `Resources/Localizable.xcstrings`.
- Exemplo do README: `Demo/Sources/Core/Review/OvationConfiguration+Levels.swift`
  e `Demo/Sources/Features/Levels/LevelsView.swift`.

## Pendências e decisões

- Decisão: nome Ovation, repositório próprio
  (`git@github.com:didisouzacosta/Ovation.git`), swift-tools 6.2, iOS 26+.
- Decisão: apresentação em sheet com o X à esquerda na toolbar, não fullscreen.
- Decisão: "já avaliou" é marcado só ao abrir "Escrever uma avaliação".
- Decisão: no máximo uma exibição por sessão, como regra interna.
- Decisão: sem avaliações reais, o integrador usa cards de destaque (sem autor,
  estrelas nem origem) ou falas dos personagens do app (só o nome do
  personagem como autor, sem o símbolo de pessoa, que fica só nas avaliações;
  2026-10-29, pedido do dono para o PotionPals).
- Decisão (2026-10-29): o sheet não chama o pedido nativo; um único botão
  "Escrever uma avaliação". O `requestReview` fica a cargo de cada app.
- Decisão (2026-10-29): textos padrão sem pedir nota específica e link de
  feedback neutro (guideline 5.6.1: sem pedir 5 estrelas e sem "review
  gating").
- Decisão (2026-10-29): origem do card é um tipo fechado (`.appStore`,
  `.testFlight`); TestFlight nunca mostra estrelas.
- Decisão (2026-10-29): carrossel paginado (não marquee contínuo), cards de
  altura fixa com conteúdo no topo, textos que truncam.
- Decisão: sheet interno; a variante `isPresented:` cobre previews e debug.
- Desvio do Figma: os cards não têm desfoque de fundo (só preenchimento branco
  a 8% e borda a 12%), para não recalcular desfoque durante a paginação.
- Decisão (2026-10-29): primeira versão publicada como `1.0.0`; o PotionPals a
  consome por versão exata.
- Pendência: compilar com Xcode 26.x / Swift 6.2; CI do Ovation.
- Ponto de atenção (App Store): "Escrever uma avaliação" usa o link documentado
  pela Apple para avaliações iniciadas pelo usuário, que a documentação de
  `RequestReviewAction` recomenda para ações da interface. O sheet é
  apresentado pelo app, não pelo usuário: mantenha-o raro, sempre fechável, sem
  estrelas tocáveis, sem recompensa, sem pedir nota específica e sem filtrar
  quem pode avaliar.
