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
  título, descrição e uma faixa de cards), leva primeiro ao pedido nativo e
  depois à página de escrever avaliação, e oferece um caminho de feedback por
  e-mail a quem não está satisfeito. O app integrador só informa os dados e
  liga um modifier com um gatilho.

## Experiência principal

Layout aprovado no Figma:
<https://www.figma.com/design/07ILZlO32KAJoY4zmtXGw1> (página "ReviewKit":
telas 01, 02 e 03, componentes e painel de regras).

### Fluxos

- Fluxo de entrada: o app integrador aplica o modifier numa View e passa um
  gatilho (`Equatable`). A cada mudança do gatilho, o pacote confere, nesta
  ordem: o usuário ainda não avaliou; o sheet ainda não apareceu nesta sessão;
  a regra configurada pelo app permite. Só então abre o sheet.
- Fluxo principal:
  1. O sheet abre (detent grande, sem grabber), em esquema escuro, com o botão
     de fechar (xmark) à esquerda na toolbar.
  2. "Continuar" chama o pedido nativo da Apple (`requestReview`) e o botão
     passa a "Escrever uma avaliação".
  3. "Escrever uma avaliação" abre
     `https://apps.apple.com/app/id<ID>?action=write-review`, marca o usuário
     como "já avaliou" e fecha o sheet.
- Fluxos alternativos:
  - "Não está feliz? Envie um feedback" abre o Mail (`mailto:`) endereçado ao
    e-mail de suporte informado. Não marca como avaliado.
  - O X (ou o gesto de arrastar) fecha o sheet. Não marca como avaliado.
  - Tocar em "Continuar" e fechar sem escrever não marca como avaliado; o
    sheet pode voltar numa sessão futura, se a regra do app permitir.

### Estados

- Botão em "Continuar" (inicial) e em "Escrever uma avaliação" (após o pedido
  nativo).
- Marquee com cards rolando continuamente; com Reduce Motion, sem rolagem
  automática; com a lista vazia, o marquee some e o conteúdo continua
  centralizado.
- Card completo (estrelas, título, texto, autor e origem) ou card de destaque
  (só título e texto, sem rodapé nem estrelas).
- Sem app de e-mail configurado: o `mailto:` pode não abrir; o comportamento
  de recuperação é definido no plano da implementação.
- Usuário que já avaliou: o sheet nunca mais aparece, em nenhuma sessão.
- Sheet já exibido nesta sessão: não reaparece até o app ser reaberto.

## Recursos e limites

- Recursos disponíveis: nenhum ainda. O repositório tem só README, LICENSE e a
  base de IA; o código do pacote está em planejamento.
- Recursos premium ou condicionais: nenhum.
- Limites conhecidos:
  - A Apple não informa se o usuário avaliou nem se o pedido nativo apareceu.
    "Já avaliou" é uma aproximação: o usuário abriu a página de escrever
    avaliação.
  - O pedido nativo segue as regras do sistema: no máximo 3 vezes em 365 dias
    por app; em desenvolvimento aparece sempre; no TestFlight não aparece.
  - Os cards devem conter avaliações reais ou destaques verdadeiros do app.
    Depoimentos inventados não podem ser apresentados como reais.
- Recursos planejados, mas ainda não conectados:
  - Configuração: App Store ID, e-mail de suporte, nome do app (padrão do
    Bundle), cards, textos sobrescrevíveis, tema e regra de exibição.
  - Textos padrão localizados no pacote em en, pt-BR, es, fr e ja. Título
    padrão em pt-BR: "Nos ajude a crescer"; descrição: "Avalie o <app> com 5
    estrelas para ajudar mais pessoas a se tornarem a melhor versão de si
    mesmas."
  - Tema: fundo, brilho inferior, estrelas do cabeçalho e dos cards, botão e
    design da fonte (padrão ou arredondada).
  - Regras prontas de exibição e uma closure própria do app.
  - Regra interna, não configurável: no máximo uma exibição por sessão.
  - Eventos para o analytics do app integrador.
  - Primeiro integrador: PotionPals.

## Dados e persistência

- Modelos: configuração, card, textos, tema e regra (value types `Sendable`).
- Fonte primária dos dados: o app integrador.
- Armazenamento local: `UserDefaults` com chaves de namespace próprio, com o
  "já avaliou" (definitivo) e os contadores que a regra precisar. A sessão fica
  só em memória, durante a vida do processo.
- Sincronização ou serviços externos: StoreKit (`requestReview`), App Store
  (URL de escrever avaliação) e Mail (`mailto:`). Sem rede própria.
- Regras de migração e recuperação: chaves estáveis; mudar o nome ou a
  semântica de uma chave é quebra de contrato e exige nota no README.

## Validação

Separe evidências de código, testes, Simulator, dispositivo físico e serviços
externos. Não trate validação local como prova de comportamento live.

- Validações concluídas: layout aprovado pelo dono no Figma (2026-10-29).
- Validações pendentes: testes unitários, build, previews e verificação visual
  no Simulator do pacote e do PotionPals integrado.
- Condições de hardware, conta ou serviço: o pedido nativo e a página de
  escrever avaliação só têm comportamento real num aparelho com a App Store e
  com o app publicado; o `mailto:` exige o Mail configurado. O Simulator não
  prova esses fluxos.

## Mapa de fontes

Ainda não há código. Atualize esta seção quando os tipos públicos, o modifier
e o sheet existirem, ligando cada fluxo ao arquivo que o implementa.

## Pendências e decisões

- Decisão: nome Ovation, repositório próprio
  (`git@github.com:didisouzacosta/Ovation.git`), Swift 6.2, iOS 26+.
- Decisão: apresentação em sheet com o X à esquerda na toolbar, não fullscreen.
- Decisão: "já avaliou" é marcado só ao abrir "Escrever uma avaliação".
- Decisão: no máximo uma exibição por sessão, como regra interna.
- Decisão: sem avaliações reais, o integrador usa cards de destaque, sem autor,
  estrelas nem origem.
- Pendência: implementar o pacote, os testes e o Demo; publicar a primeira
  versão com tag para o PotionPals consumir por versão exata.
- Risco: a guideline 5.6.1 da App Store exige a API oficial para pedir
  avaliação e não aceita prompts de avaliação próprios. O sheet não coleta nota
  (as estrelas são decorativas, não interativas) e só encaminha para o pedido
  nativo e para a página oficial de escrever avaliação.
- Próximo passo: plano do Manager (nível 2) e implementação com TDD.
