# AgroTech

App Flutter de monitoramento IoT de cultivo: lê os sensores da plantação, aciona a bomba de irrigação, mostra o clima da região e conversa com um assistente. Projeto Integrador da equipe D3G Technology; o código do app fica em [`appintegra/`](appintegra).

## Funcionalidades

O app abre numa tela de apresentação e cai numa barra com cinco abas:

| Aba | O que faz | De onde vêm os dados |
|---|---|---|
| **Atuadores** | Liga e desliga a bomba de irrigação e lê os sensores sob demanda. Avisa quando a API não responde. | `POST /bomba` (`{"estado": 0 ou 1}`) e `GET /dados` da API |
| **Sensores** | Umidade do ar, temperatura do ar, umidade do solo e pH, cada um com status Bom / Atenção / Ruim e uma tela de detalhe. Atualiza pelo ícone ou puxando a lista. | `GET /dados` da API |
| **Home** | Carrossel de imagens e cartão do clima atual (temperatura, mínima e máxima, condição com ícone de dia ou noite); ao tocar, detalhes: umidade, nebulosidade, chuva, vento, nascer e pôr do sol, fase da lua, fuso. | HG Brasil Weather (cidade pelo IP) |
| **Chat** | Conversa com um assistente: cada mensagem vai para um fluxo do Langflow e a resposta volta na tela. | Langflow em um Space do Hugging Face |
| **Ajustes** | Tela de configurações (perfil, notificações, aparência, idioma...). Ainda é ilustrativa: os itens não têm ação. | — |

Quando a API dos sensores não responde ou não há chave da HG Brasil, as telas entram em **modo demonstração**: mostram valores de exemplo com a faixa "Dados de exemplo" e o motivo, em vez de ficar vazias ou quebrar.

## Arquitetura

```
sensores e bomba (microcontrolador) ──> API (FastAPI, publicada no Railway) ──> app Flutter
                                          GET /dados          POST /bomba        Atuadores, Sensores

HG Brasil Weather ─────────────────────────────────────────────────────────────> aba Home
Langflow (Space no Hugging Face) ─────────────────────────────────────────────> aba Chat
```

- `GET /dados` devolve `{"temperatura", "umidade", "sensor_umidsolo", "pH", "bomba"}`; `POST /bomba` recebe `{"estado": 1}` para ligar e `{"estado": 0}` para desligar.
- **O firmware do microcontrolador e o código da API não estão neste repositório.** A instância da API no Railway está fora do ar, por isso o app, hoje, roda em modo demonstração nas abas Atuadores e Sensores. Com uma API no mesmo formato, basta apontar `API_URL` para ela.
- Os endereços ficam em [`appintegra/lib/config.dart`](appintegra/lib/config.dart) e podem ser trocados em tempo de compilação.

## Como rodar

Requisitos: Flutter 3.29.x (Dart 3.7) e, para Android, JDK 17. O projeto Android está em AGP 8.1.0 / Gradle 8.3 / Kotlin 1.8.22, que versões bem mais novas do Flutter já não aceitam.

```bash
cd appintegra
flutter pub get
flutter run --dart-define=HG_KEY=sua_chave --dart-define=API_URL=http://192.168.0.10:8000
```

| `--dart-define` | Para que serve | Sem informar |
|---|---|---|
| `HG_KEY` | Chave da HG Brasil Weather | Clima em modo demonstração |
| `API_URL` | Endereço da API dos sensores (sem barra no fim) | Instância do Railway (fora do ar) |
| `LANGFLOW_URL` | Endpoint `/api/v1/run/<fluxo>` do Langflow | Space do Hugging Face usado no projeto |

**Chave gratuita da HG Brasil:** crie uma conta em <https://console.hgbrasil.com>, ative a API *Weather* e copie a chave; o plano gratuito basta para testes. Nunca grave a chave no código: use o `--dart-define`.

**Versão web local:** a pasta `web/` não está no repositório. Gere-a uma vez com `flutter create --platforms web .` dentro de `appintegra/` e rode com `flutter run -d chrome --dart-define=HG_KEY=...`.

## Demonstração

- **Web:** <https://diogusvincere.github.io/agrotech-app/ (numa moldura de celular; `…/agrotech-app/app/` abre em tela cheia)> — publicada pelo workflow [`web.yml`](.github/workflows/web.yml) a cada push na `main`. Sem o segredo `HG_KEY` e com a API fora do ar, aparece em modo demonstração.
- **APK:** na página de [Releases](https://github.com/DiogusVincere/agrotech-app/releases) (gerado pelo workflow [`apk.yml`](.github/workflows/apk.yml) a cada tag `v*`; cada execução também deixa o APK como artefato). O APK é assinado com a chave de debug: instala em qualquer aparelho Android, mas não serve para a Play Store.

<!-- prints: adicionar -->

## Equipe

D3G Technology — Diogo Vieira de Lima ([@DiogusVincere](https://github.com/DiogusVincere)) e equipe.

## Licença

[MIT](LICENSE).
