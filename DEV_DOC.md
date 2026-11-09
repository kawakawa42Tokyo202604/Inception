# Inception の開発・環境構築

Docker環境の準備、設定、ビルドと検証の手順です。この構成は `student` ユーザーを使うLinux VMを想定しています。コマンドは Inception のルートで実行します。

Setup and development notes for the Docker Compose stack.

## ファイルの配置

| 場所 | 役割 |
| --- | --- |
| `Makefile` | ビルド・起動・検証の入口 |
| `srcs/docker-compose.yml` | サービス・ネットワーク・ボリューム・secretの定義 |
| `srcs/requirements/` | 各サービスのDockerfile・設定・起動スクリプト |
| `srcs/tools/` | 設定検査・secret生成・ストレージ準備 |
| `srcs/docker/` | Dockerデーモン設定例・管理ヘルパー |
| `srcs/tests/` | モックと一時領域を使う回帰テスト |
| `secrets/` | ローカルのパスワードファイル |

<a id="vm-setup"></a>

## VMの初期設定

Docker Engine・Compose v2・Make・OpenSSL が必要です。ストレージ管理には systemd・sudo・findmnt・flock を使用します。

Dockerの `data-root` を `/home/student/data/docker` に設定します。[daemon.json](srcs/docker/daemon.json) を参考に `/etc/docker/daemon.json` へ設定を追加してください。既存の設定は残し、既存データがある環境では移行を済ませてから切り替えます。

VM管理者として、ユーザーのDockerアクセスと管理ヘルパーを準備します。

```sh
/usr/sbin/usermod -aG docker student
sh ./srcs/tools/install-storage-admin.sh
systemctl restart docker.service
```

ヘルパーは `/usr/local/sbin/inception-storage-admin` に、専用sudo設定は `/etc/sudoers.d/inception-storage` に配置されます。`check`・`clean-data`・`recover` の3操作を扱います。

`student` でログインし直し、設定を確認します。

```sh
docker compose version
docker info --format '{{.DockerRootDir}}'
```

<a id="configuration"></a>

## 環境ファイルと認証情報

```sh
test -e srcs/.env || cp srcs/.env.example srcs/.env
```

`srcs/.env` を開き、次の値を設定します。

| 項目 | 内容 |
| --- | --- |
| `DOMAIN_NAME` | サイトのドメイン（既定は `student.42.fr`） |
| `MYSQL_DATABASE` / `MYSQL_USER` | DB名とアプリ用DBユーザー |
| `WORDPRESS_ADMIN_USER` / `WORDPRESS_ADMIN_EMAIL` | WordPress管理者 |
| `WORDPRESS_USER` / `WORDPRESS_USER_EMAIL` | WordPress一般ユーザー |
| `FTP_USER` / `FTP_PASV_ADDRESS` | FTPのユーザー名と接続先アドレス |
| `BACKUP_SCHEDULE` / `BACKUP_RETENTION` | cronの5フィールド形式の実行時刻と保持世代数 |

WordPressの2組のユーザー名・メールアドレスはそれぞれ異なる値にします。ユーザー名はASCII英数字と `. _ -` を使い、管理者名には大文字小文字を問わず `admin` を含められません。

ブラウザーを使う端末のDNSまたは `/etc/hosts` で、VMのIPを `DOMAIN_NAME` に対応付けます。

```sh
./srcs/tools/generate-secrets.sh
make check-config
```

secret生成は6個のパスワードファイルを作り、既存ファイルは維持します。`secrets/` は700、パスワードファイルは600相当の所有者限定の権限で管理します。`srcs/.env` とsecretはGitの追跡対象外です。

## ビルドと開発

```sh
make
make ps
```

`make` はストレージの準備・設定検査・イメージのビルド・起動を順に実行します。Dockerfileやサービス設定を編集した後も `make` で反映できます。`make build` はビルドまで、`make logs` はログの追跡です。

NGINXがHTTPSを受け、WordPressへFastCGIで渡し、WordPressがMariaDBとRedisを使います。サービス名・ポート・ボリュームを変更した場合は Compose と利用者ガイドも合わせて更新します。

## データと停止

| ボリューム | 保存内容 |
| --- | --- |
| `inception_mariadb_data` | MariaDBのデータ |
| `inception_wordpress_data` | WordPressのファイル |
| `inception_backup_data` | バックアップの各世代 |

`make stop`・`make down`・`make clean` は永続データを保持します。`make fclean` はVM内の全Dockerコンテナ・イメージ・ボリューム・カスタムネットワークと `/home/student/data/*` を削除する完全初期化です。サイトとバックアップも消えるため、通常の停止には使いません。

`DATA_DIR` はMakeが検査する保存先を指定する値です。Dockerデーモンの設定自体は変更しません。管理ヘルパーの保存先は `student` 用に固定されています。

<a id="testing"></a>

## 検証

```sh
make test
```

ストレージ復旧・完全初期化・管理ヘルパー・認証・FTP・バックアップと復元の回帰テストを実行します。Dockerとシステム操作はモックに置き換え、実データには触れません。

実環境の確認は `make check-config`・`make ps`・サイトへのアクセスで行います。バックアップは `make backup`、一時環境での復元検証は `make restore-check` を使います。保存先を失った場合の動作は [ストレージ復旧](srcs/docker/STORAGE_RECOVERY.md) を参照してください。
