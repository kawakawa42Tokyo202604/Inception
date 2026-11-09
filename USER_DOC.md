# Inception の使い方

サイトの起動・ログイン・停止・バックアップの操作をまとめています。初回の環境構築は [開発者ガイド](DEV_DOC.md) を参照してください。コマンドは Inception のルートで実行します。

A short guide to running the site, signing in, and managing backups.

## 起動とアクセス

```sh
make
make ps
```

既定のURLは次のとおりです。ブラウザーを使う端末から `student.42.fr` がVMのIPに解決できる必要があります。

| 用途 | URL |
| --- | --- |
| WordPress | `https://student.42.fr` |
| WordPress管理画面 | `https://student.42.fr/wp-admin/` |
| 静的サイト | `http://student.42.fr:8080/` |
| Adminer（VM内） | `http://127.0.0.1:8081/` |

HTTPSには自己署名証明書を使います。`make browser` で、通常の名前解決を使ってブラウザーを開けます。

## ログイン情報

ユーザー名は `srcs/.env`、初期パスワードは `secrets/` の対応ファイルで確認します。

| 用途 | ユーザー名の設定 | パスワードファイル |
| --- | --- | --- |
| WordPress管理者 | `WORDPRESS_ADMIN_USER` | `wp_admin_password.txt` |
| WordPress一般ユーザー | `WORDPRESS_USER` | `wp_user_password.txt` |
| MariaDB / Adminer | `MYSQL_USER` | `db_password.txt` |
| FTP | `FTP_USER` | `ftp_password.txt` |

Adminer のサーバー名は `mariadb`、データベース名は `MYSQL_DATABASE` です。既存のWordPressアカウントを変更するときは管理画面を使います。

## 日常の操作

| コマンド | 動作 |
| --- | --- |
| `make ps` | コンテナの状態とポートを確認 |
| `make logs` | ログを追跡（Ctrl-Cで終了） |
| `make stop` / `make start` | 停止・再開 |
| `make restart` | 既存コンテナを再起動 |
| `make` | イメージをビルドして起動・更新 |
| `make down` | コンテナとネットワークを削除し、永続データは保持 |

DB・WordPressファイル・バックアップは名前付きボリュームに保存されます。

<a id="backup"></a>

## バックアップ

```sh
make backup
make restore-check
```

`make backup` はDBとWordPressファイルのバックアップを作成します。`make restore-check` は新しく作成した世代のチェックサムを確認し、一時DBへ復元して内容を検証します。稼働中のサイトデータは書き換えません。

保存先は `inception_backup_data` ボリュームです。定期実行の時刻と保持数は `srcs/.env` の `BACKUP_SCHEDULE`・`BACKUP_RETENTION` で指定します。

## FTP

VM内から `127.0.0.1:21` に接続し、パッシブモードには21100〜21110番ポートを使います。FTPとAdminerは既定でVMのループバックに公開します。外部端末から使う場合はSSHトンネルなどでVM内の待受先へ接続します。

## 困ったとき

| 症状 | 確認すること |
| --- | --- |
| サイトが開かない | ドメインの名前解決、VMのIP、443番ポート、`make ps` |
| 起動時の設定エラー | `make check-config` と [設定手順](DEV_DOC.md#configuration) |
| サービスが再起動を繰り返す | `make logs` の該当サービスのエラー |
| Dockerの保存先が見つからない | [ストレージ復旧](srcs/docker/STORAGE_RECOVERY.md) |
