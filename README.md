# ObraTech

Sistema mobile inteligente para monitoramento e gerenciamento de obras, com integração IoT via ESP32 e MQTT.


# Sobre o Projeto

O ObraTech é um aplicativo mobile desenvolvido em Flutter como projeto integrador do curso de Engenharia de Software (4° período) — Centro Universitário Campo Real.

O sistema permite:
- Cadastrar e gerenciar obras e funcionários
- Monitorar temperatura e umidade em tempo real via sensor ESP32
- Registrar ponto de funcionários via RFID (ESP32 + MQTT)
- Disparar alertas automáticos por temperatura crítica
- Consultar histórico de alertas e atividades


# Tecnologias Utilizadas

| Camada | Tecnologia |
|--------|-----------|
| Mobile | Flutter (Dart) |
| Gerenciamento de estado | Provider |
| Banco de dados local | SQLite (sqflite) |
| Comunicação IoT | MQTT (broker HiveMQ público) |
| Dispositivo IoT | ESP32 + sensor DHT22 + módulo RFID |


# Estrutura do Projeto

```
lib/
├── main.dart                   # Entrada da aplicação
├── models/                     # Modelos de dados
│   ├── alerta.dart
│   ├── funcionario.dart
│   ├── obra.dart
│   └── usuario.dart
├── providers/                  # Gerenciamento de estado (Provider)
│   ├── alerta_provider.dart
│   ├── auth_provider.dart
│   ├── funcionario_provider.dart
│   └── obra_provider.dart
├── routes/
│   └── app_routes.dart         # Definição de rotas nomeadas
├── screens/                    # Telas do aplicativo
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── reset_senha_screen.dart
│   ├── home_screen.dart        # Dashboard + navegação principal
│   ├── obras_screen.dart
│   ├── add_obra_screen.dart
│   ├── detalhe_obra_screen.dart
│   ├── funcionarios_screen.dart
│   ├── cartao_ponto_screen.dart
│   ├── iot_screen.dart         # Monitoramento em tempo real
│   └── alertas_screen.dart
├── services/
│   ├── database_service.dart   # Singleton SQLite
│   └── mqtt_service.dart       # Cliente MQTT
├── theme/
│   └── app_theme.dart
└── widgets/
    └── iot_chart.dart
```


# Como Executar o Aplicativo

# Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — versão 3.11.3 ou superior
- Android Studio ou VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico

# Passo a passo

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/obra_tech.git
cd obra_tech

# 2. Instale as dependências
flutter pub get

# 3. Verifique se o ambiente está configurado
flutter doctor

# 4. Execute o aplicativo
flutter run
 

# Criar conta de acesso

Na tela de login, toque em **"Criar conta"** e preencha nome, e-mail e senha. Após o cadastro, faça login com as mesmas credenciais.


# Configuração da API / MQTT

O ObraTech não utiliza uma API REST própria — a comunicação com o dispositivo IoT é feita diretamente via **MQTT** usando o broker público da HiveMQ.

### Configurações do broker

| Parâmetro | Valor |
|-----------|-------|
| Broker | `broker.hivemq.com` |
| Porta | `1883` |
| Client ID | `obratech_app` |
| Tópico temperatura | `obra/temperatura` |
| Tópico ponto RFID | `obra/ponto` |

As configurações estão em `lib/services/mqtt_service.dart`. Para usar um broker privado, altere o endereço e porta no construtor:

```dart
// lib/services/mqtt_service.dart
final client = MqttServerClient('SEU_BROKER_AQUI', 'obratech_app');
client.port = 1883; // altere se necessário
```

### Formato das mensagens MQTT

**Tópico `obra/temperatura`** — o ESP32 publica temperatura e umidade separados por vírgula:
```
28.5,65.3
```
*(temperatura em °C, umidade em %)*

**Tópico `obra/ponto`** — o ESP32 publica o ID do cartão RFID lido:
```
ABC123
```
*(deve corresponder ao ID do funcionário cadastrado no app)*

---

#  Dispositivo IoT — ESP32

### Hardware necessário

- ESP32 (qualquer variante com Wi-Fi)
- Sensor DHT22 (temperatura e umidade)
- Módulo RFID RC522 (opcional, para controle de ponto)

### Funcionamento

O ESP32 conecta-se à rede Wi-Fi, estabelece conexão MQTT com o broker HiveMQ e publica periodicamente (a cada 5 segundos) os dados lidos pelo sensor DHT22 no tópico `obra/temperatura`.

Quando um cartão RFID é aproximado do módulo RC522, o ESP32 publica o UID do cartão no tópico `obra/ponto`. O aplicativo identifica o funcionário pelo ID cadastrado e registra automaticamente a batida de ponto com horário.

### Código do ESP32

O código-fonte do firmware está na pasta `/iot` do repositório (`firmware_esp32.ino`).

**Configurações que devem ser editadas no firmware antes de gravar:**

```cpp
// Configurações Wi-Fi
const char* ssid     = "NOME_DA_SUA_REDE";
const char* password = "SENHA_DA_REDE";

// Broker MQTT
const char* mqtt_server = "broker.hivemq.com";
const int   mqtt_port   = 1883;

// Tópicos
const char* topic_temp  = "obra/temperatura";
const char* topic_ponto = "obra/ponto";
```

### Fluxo de dados

```
ESP32 (DHT22) → publica no broker MQTT → app Flutter recebe e exibe em tempo real
ESP32 (RFID)  → publica UID no broker  → app identifica funcionário e registra ponto
```

---

# Telas do Aplicativo

| Tela | Descrição |
|------|-----------|
| Login | Autenticação com e-mail e senha |
| Cadastro | Criação de nova conta de usuário |
| Recuperar senha | Redefinição de senha por e-mail |
| Dashboard (Home) | Resumo geral: obra atual, alertas, temperatura e atividades recentes |
| Obras | Listagem de obras cadastradas |
| Detalhe da Obra | Informações completas de uma obra específica |
| Adicionar Obra | Formulário de cadastro de obra |
| Funcionários | Listagem de funcionários com obra vinculada |
| Cartão de Ponto | Histórico de batidas de ponto de um funcionário |
| IoT — Sensores | Monitoramento em tempo real: temperatura, umidade, gráfico ao vivo e regras de alerta |
| Alertas | Histórico completo de alertas gerados pelo sistema |
| Perfil | Edição de dados do usuário logado |

---

# Banco de Dados

O banco de dados local (SQLite) contém as seguintes tabelas:

| Tabela | Descrição |
|--------|-----------|
| `usuarios` | Contas de acesso ao aplicativo |
| `obras` | Obras cadastradas |
| `funcionarios` | Funcionários com vínculo a obras |
| `alertas` | Histórico de alertas gerados |

---

# Regras de Alerta (IoT)

O sistema dispara alertas automáticos conforme os dados recebidos do sensor:

| Condição | Nível |
|----------|-------|
| Temperatura > 36 °C | 🔴 CRÍTICO |
| Temperatura > 30 °C | 🟠 ATENÇÃO |
| Umidade > 80% | 🔵 UMIDADE ALTA |

---

## 👩‍💻 Integrantes

| Nome | Responsabilidade |
|------|-----------------|
| Ana Clara | [descrever] |
| Kauana Cravelin | [descrever] |
| Samara | [descrever] |

---

# Informações Acadêmicas

**Curso:** Engenharia de Software — 4° Período  
**Instituição:** Centro Universitário Campo Real  
**Desafio Integrador:** Aplicativo Mobile Inteligente com Integração IoT  
**Professores orientadores:**
- Brenda Lopes Levandoski — Desenvolvimento Web/Mobile
- Luan Costa — Internet das Coisas / Redes / Robótica