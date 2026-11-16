# Inception

## English

A Docker environment for a WordPress site where users can publish and read posts in a browser. It combines NGINX for web connections, WordPress for the site, and MariaDB for posts and user information.

Each service runs in an isolated container, started together through Docker Compose. The site supports HTTPS and retains its posts and configuration when containers are stopped or recreated.

### Services

| Service | Purpose |
| --- | --- |
| NGINX | Accept browser HTTPS connections on port 443 |
| WordPress + PHP-FPM | Publish and display posts and execute WordPress PHP code |
| MariaDB | Store posts, users, and settings |
| Redis | Cache frequently used data to speed up repeated access |
| FTP / static site / Adminer | File transfer, static pages, and a database administration page |
| Backup / Restore-check | Scheduled backups and restoration checks in a temporary environment |

### Build and start

Requires a Linux VM, Docker Engine, Docker Compose v2, Make, and OpenSSL. First prepare Docker permissions, the storage helper, and Docker's data-root (default `/home/student/data/docker`) using the [development setup guide](DEV_DOC.md#vm-setup).

Prepare the environment file from the project root:

```sh
test -e srcs/.env || cp srcs/.env.example srcs/.env
```

Set the domain and two WordPress username/email pairs in `srcs/.env`. On the computer running your browser, map the domain to the VM's IP using DNS or `/etc/hosts`. See this project's [configuration guide](DEV_DOC.md#configuration) for the available settings.

```sh
./srcs/tools/generate-secrets.sh
make
make ps
```

After startup, open the site in a browser and create posts through the administration page. The default URLs are `https://student.42.fr` and `https://student.42.fr/wp-admin/`. A self-signed certificate is used.

### Common commands

| Command | Action |
| --- | --- |
| `make logs` | Display service logs |
| `make stop` / `make start` | Stop or restart containers |
| `make down` | Remove containers and networks while retaining persistent data |
| `make backup` | Create a backup immediately |
| `make restore-check` | Restore a new backup in a temporary environment and check it |

### Tests

```sh
make test
```

Runs storage recovery, cleanup, administration-helper, and service regression checks using temporary directories and mocks.

### Implementation

- Separate Dockerfiles for each service, connected through a dedicated network.
- Named volumes for the database, WordPress files, and backups.
- Password files in `secrets/`, with regular configuration in `srcs/.env`.

This project's [user guide](USER_DOC.md) covers daily operation; the [developer guide](DEV_DOC.md) covers setup, configuration, and development.

### Tests

```sh
make test
```

`make test` runs isolated shell regression tests without starting containers. To inspect an already running VM stack, use `make test-live`; it verifies configuration, core-service health, and HTTPS without starting or stopping services. Prepare the VM, local environment file, and secrets first.

## 日本語

ブラウザーから記事を投稿・閲覧できるWordPressサイトを、Dockerで構築するプロジェクトです。Webへの接続を受けるNGINX、サイトを動かすWordPress、記事やユーザー情報を保存するMariaDBを組み合わせます。

各サービスを独立した実行環境（コンテナ）で動かし、Docker Composeでまとめて起動します。HTTPSでアクセスでき、コンテナを停止・再作成しても記事や設定が残る構成です。

### サービス

| サービス | 役割 |
| --- | --- |
| NGINX | ブラウザーからのHTTPS接続を受け付けるWebサーバー（443番ポート） |
| WordPress + PHP-FPM | 記事の投稿・表示と、WordPressのPHPコードの実行 |
| MariaDB | 記事・ユーザー・設定などを保存するデータベース |
| Redis | よく使うデータを一時保存し、繰り返しの取得を速める |
| FTP / 静的サイト / Adminer | ファイル転送、静的ページ配信、DB管理画面 |
| Backup / Restore-check | 定期バックアップと、一時環境での復元検証 |

### ビルドと起動

Linux VM・Docker Engine・Docker Compose v2・Make・OpenSSL が必要です。初回は [開発者向け手順](DEV_DOC.md#vm-setup) に従い、Dockerの実行権限・ストレージ管理ヘルパー・data-root（既定は `/home/student/data/docker`）を準備します。

リポジトリ直下で環境ファイルを用意します。

```sh
test -e srcs/.env || cp srcs/.env.example srcs/.env
```

`srcs/.env` のドメイン名と、WordPress用の2組のユーザー名・メールアドレスを設定します。ブラウザーを使う端末のDNSまたは `/etc/hosts` で、VMのIPをそのドメイン名に対応付けてください。設定項目の詳細は [環境ファイルの説明](DEV_DOC.md#configuration) にあります。

```sh
./srcs/tools/generate-secrets.sh
make
make ps
```

起動後はブラウザーでサイトにアクセスし、管理画面から記事を作成できます。既定のサイトURLは `https://student.42.fr`、管理画面は `https://student.42.fr/wp-admin/` です。自己署名証明書を使用します。

### 主な操作

| コマンド | 動作 |
| --- | --- |
| `make logs` | サービスのログを表示 |
| `make stop` / `make start` | コンテナを停止・再開 |
| `make down` | コンテナとネットワークを削除し、永続データは保持 |
| `make backup` | バックアップを即時作成 |
| `make restore-check` | 新しいバックアップを一時環境に復元して検証 |

### 検証

```sh
make test
```

ストレージ復旧・クリーンアップ・管理ヘルパー・各サービスの回帰テストを、一時領域とモックで実行します。

### 実装メモ

- サービスごとに Dockerfile を分け、専用ネットワークで接続します。
- DB・WordPressファイル・バックアップは名前付きボリュームに保存します。
- パスワードは `secrets/` のファイルで渡し、通常の設定は `srcs/.env` に分けています。

詳しい操作は [利用者ガイド](USER_DOC.md)、構築・開発手順は [開発者ガイド](DEV_DOC.md) を参照してください。

### テスト

```sh
make test
```

`make test` はコンテナを起動せず、隔離したシェルの回帰テストを実行します。起動済みVMの実機確認は `make test-live` で行い、設定・主要サービスの正常性・HTTPSを検証します。サービスの起動・停止は行いません。VMとローカルの環境設定・秘密ファイルを事前に用意します。
