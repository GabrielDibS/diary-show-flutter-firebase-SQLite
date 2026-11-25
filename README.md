# Diário de Shows

Aplicativo mobile em **Flutter** para registrar os shows e eventos musicais que você assistiu ou vai assistir, com **Firebase** (autenticação e nuvem), **SQLite** (armazenamento local), funcionamento **offline first**, **GPS**, **calendário** e consulta à API **TheAudioDB**.

## Integrantes

- Gabriel — _(preencher sobrenome)_
- _(nome do colega, se for em dupla)_

## Objetivo

Permitir que cada usuário cadastre seus shows (título, artista, local, data, descrição, foto e coordenadas de GPS), consulte-os em lista e em calendário, e continue usando o app mesmo sem internet — os dados são enviados ao Firebase automaticamente quando a conexão volta.

## Tecnologias

Flutter e Dart · Firebase Authentication · Cloud Firestore · SQLite (sqflite) · API REST TheAudioDB (v1, chave gratuita)

## Bibliotecas utilizadas

| Pacote | Finalidade |
|---|---|
| firebase_core | Inicialização do Firebase |
| firebase_auth | Login, cadastro e recuperação de senha |
| cloud_firestore | Banco de dados na nuvem |
| sqflite + path | Banco de dados local (SQLite) |
| path_provider | Pasta do aplicativo (guarda as fotos) |
| connectivity_plus | Detectar queda e volta da internet |
| geolocator | Permissão e coordenadas do GPS |
| table_calendar | Calendário interativo |
| image_picker | Foto pela galeria ou câmera |
| http | Requisições à API TheAudioDB |
| url_launcher | Abrir links (mapa, redes sociais, YouTube) |
| uuid | Identificador único de cada registro |
| intl + flutter_localizations | Datas e calendário em português |

## Estrutura do projeto

```
lib/
├── main.dart                    inicializa Firebase, tema e a splash
├── firebase_options.dart        gerado pelo "flutterfire configure"
├── theme/app_theme.dart         cores e tema escuro
├── models/registro_model.dart   modelo do registro (SQLite e Firestore)
├── database/
│   ├── local_database.dart      abre o banco e cria a tabela
│   └── registro_helper.dart     CRUD local (inserir, consultar, atualizar, excluir)
├── services/
│   ├── auth_service.dart        Firebase Authentication
│   ├── firestore_service.dart   CRUD no Firestore
│   ├── sync_service.dart        detecta internet e sincroniza pendentes
│   ├── registro_repository.dart regra offline first (une SQLite + Firestore)
│   ├── location_service.dart    GPS e permissões
│   ├── api_service.dart         requisições à TheAudioDB
│   └── api_exceptions.dart      erros de conexão e de API
├── views/                       telas (splash, login, cadastro, home, lista, formulário, detalhes, calendário e telas da API)
├── components/                  campo de texto, botão e layout de autenticação
├── widgets/                     peças de interface reutilizáveis
└── utils/                       validadores, formatadores, links e YouTube
```

## Como funciona o offline first

1. Todo cadastro, edição ou exclusão é gravado primeiro no **SQLite** com `synced = 0`.
2. Se houver internet, o `SyncService` envia o registro ao **Firestore** e, após a confirmação, **apaga a cópia local**.
3. Sem internet, o registro fica no SQLite (continua visível, editável e excluível, mesmo depois de fechar o app).
4. Quando a internet volta, o `connectivity_plus` avisa o `SyncService`, que envia todos os pendentes.
5. **Sem duplicar:** o `id` é um UUID gerado no aparelho e é usado também como id do documento no Firestore. Reenviar o mesmo registro apenas sobrescreve o documento.
6. **Exclusão offline:** o registro recebe `deletedAt` (fica oculto) e, ao sincronizar, o documento é apagado no Firestore e só então a linha local é removida.
7. Na lista, o app une os registros da nuvem com os pendentes locais (o local prevalece quando o `id` é o mesmo).

## Configuração do Firebase (necessária para executar)

1. No [Firebase Console](https://console.firebase.google.com), crie um projeto.
2. **Authentication → Método de login → E-mail/senha → Ativar.**
3. **Firestore Database → Criar banco de dados.** Depois, em **Regras**, cole o conteúdo do arquivo `firestore.rules` deste repositório e publique.
4. Instale as ferramentas (uma vez): Node.js, depois no terminal:
   ```
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```
5. Na pasta do projeto, rode `flutterfire configure`, escolha o projeto criado e marque **Android**. Isso gera o `lib/firebase_options.dart` (e ajusta os arquivos do Android).
6. Rode `flutter pub get`.

> O `firebase_options.dart` e o `google-services.json` contêm apenas identificadores públicos do projeto Firebase (não são chaves privadas); quem protege os dados são as regras do Firestore e a autenticação. **Nunca** publique senhas nem arquivos de conta de serviço (`serviceAccount*.json`).

## Como executar

```
flutter pub get
flutter run
```

Para gerar o APK: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`

Para regenerar o ícone e a splash nativa (opcional): `dart run flutter_launcher_icons` e `dart run flutter_native_splash:create`.

## Funcionalidades implementadas

- Nome próprio, ícone personalizado, splash screen animada, tema padronizado, layout adaptável (1 ou 2 colunas conforme a largura)
- Login, cadastro (com confirmação de senha) e recuperação de senha com Firebase Authentication de verdade
- Tela principal com identificação do usuário, logout e acesso às funções
- CRUD completo de shows no **Firestore** (`users/{uid}/registros/{id}`) e no **SQLite**
- Offline first com sincronização automática, sem duplicar e com exclusão offline replicada
- Geolocalização (permissão explicada, verificação do GPS, latitude/longitude exibidas e salvas no registro)
- Calendário (`table_calendar`) com marcadores nos dias com shows, seleção de data e cadastro na data escolhida
- Fotos pela galeria ou câmera, associadas ao registro (arquivo guardado no aparelho)
- Consumo da API TheAudioDB com `http`: telas Artista, Música mais tocada e Álbuns, e dados do artista nos detalhes do show
- Botões: `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton` e `FloatingActionButton`

## Roteiro de teste

1. Abrir o app → 2. Criar conta → 3. Encerrar → 4. Abrir e fazer login → 5. Cadastrar um show → 6. Ver na lista → 7. Abrir o calendário e escolher a data → 8. Ver o show → 9. Obter a localização → 10. Associar ao registro → 11. Editar → 12. Excluir → 13. Conferir no Firebase Console → 14. Desligar a internet → 15. Cadastrar outro show → 16. Fechar e abrir o app → 17. Conferir que o registro continua lá (marcado como pendente) → 18. Ligar a internet → 19. Conferir no Firebase que o registro foi sincronizado.

## Telas

_(adicionar aqui os prints das principais telas, por exemplo em `docs/screenshots/`)_
